//
//  DataCenter.m
//  Momo
//
//  Created by Jeheon Choi on 2017. 3. 27..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import "DataCenter.h"

// Class Extensions -----------------------------------//

@interface DataCenter ()

@end




// Class implementation -------------------------------//

@implementation DataCenter

#pragma mark - DataCenter Singleton Instance

// 싱글턴 객체 호출 메소드
+ (instancetype)sharedInstance {
    
    static DataCenter *data;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        data = [[self alloc] init];
    });
    
    return data;
}




// MOMO Dataset 관련 -----------------------------------//
#pragma mark - MOMO Dataset 관련

+ (RLMArray<MomoMapDataSet *> *)myMapList {
    return [DataCenter sharedInstance].momoUserData.user_map_list;
}

+ (RLMArray<MomoPinDataSet *> *)myPinListWithMapIndex:(NSInteger)mapIndex {
    return [DataCenter myMapList][mapIndex].map_pin_list;
}

+ (RLMArray<MomoPostDataSet *> *)myPostListWithMapIndex:(NSInteger)mapIndex WithPinIndex:(NSInteger)pinIndex {
    return [DataCenter myPinListWithMapIndex:mapIndex][pinIndex].pin_post_list;
}




// Account Token 자동로그인 ------------------------------//
#pragma mark - Auto Login / Token getter

- (NSString *)getUserToken {
    // Token 없으면 nil
    return [DataCenter sharedInstance].momoUserData.user_token;
}


// User Data 저장, 패치, 삭제 --------------------------//
#pragma mark - MOMO User Data 저장, 패치, 삭제

// 초기 저장
// 최초 객체 세팅 후, Realm에 addObject할 때만 부름
+ (void)initialSaveMomoUserData {
    NSLog(@"saveMomoUserData : %@", [DataCenter sharedInstance].momoUserData);
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
        [realm addObject:[DataCenter sharedInstance].momoUserData];
    }];
    
    NSLog(@"realm url : %@", realm.configuration.fileURL);
}

// 패치
- (void)fetchMomoUserDataWithCompletionBlock:(void (^)(BOOL isSuccess))completionBlock {
    
    // 기존 저장되어있던 기본 데이터들 패치 (페북 & 이메일 공통)
    if([MomoUserDataSet allObjects].firstObject) {     // nil이 아닐 때 불러옴
        [DataCenter sharedInstance].momoUserData = [MomoUserDataSet allObjectsInRealm:[RLMRealm defaultRealm]].firstObject;    // 첫번째 UserData가 내 계정

        NSLog(@"token : %@, count : %ld =? %ld", [DataCenter sharedInstance].momoUserData.user_token, [MomoUserDataSet allObjectsInRealm:[RLMRealm defaultRealm]].count, [MomoUserDataSet allObjects].count);
        
        [NetworkModule getMemberProfileRequestWithCompletionBlock:^(BOOL isSuccess, NSString *result) {
            
            if (isSuccess) {
                NSLog(@"get Member Profile success : %@", result);

                completionBlock(YES);
                
            } else {
                NSLog(@"get Member Profile Request error : %@", result);
                [DataCenter removeMomoUserData];
                [DataCenter sharedInstance].momoUserData = [[MomoUserDataSet alloc] init];
                
                completionBlock(NO);
                
            }
        }];
        
    } else {    // 토큰 없을 때
        [DataCenter sharedInstance].momoUserData = [[MomoUserDataSet alloc] init];
        
        completionBlock(NO);
    }
}

// 삭제
+ (void)removeMomoUserData {
    
    NSLog(@"removeUserData %@", [DataCenter sharedInstance].momoUserData);
    NSLog(@"user_token : %@", [DataCenter sharedInstance].momoUserData.user_token);

    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
        [realm deleteAllObjects];
    }];

}


+ (void)momogetMemberProfileDicParsingAndUpdate:(NSDictionary *)responseDic {
    
    // realm transaction
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{

        // 추가 User 정보
        [DataCenter sharedInstance].momoUserData.user_username = [responseDic objectForKey:@"username"];
        
        if ([responseDic objectForKey:@"email"]) {
            [DataCenter sharedInstance].momoUserData.user_email = [responseDic objectForKey:@"email"];
        }
        if ([[responseDic objectForKey:@"profile_img"] objectForKey:@"full_size"]) {
            [DataCenter sharedInstance].momoUserData.user_profile_image_url = [[responseDic objectForKey:@"profile_img"] objectForKey:@"full_size"];
        }

        // 기존 데이터, 새로 생성된 데이터 구별했으나, 어차피 다른 디바이스에서 같은 계정으로 데이터 삭제 되있었을 때
        // 삭제에 관한 부분(RLMArray 해당 index 삭제까지) 복잡하게 처리할 바에야 그냥 전부 데이터 받아오니, 다시 세팅하는 방식으로 함
        // 추후, create_date기반으로 update 된 부분만 서버에서 보내주는 API가 나온다면 전부 삭제하는 로직 없앨 것.
        [[DataCenter myMapList] removeAllObjects];
        [realm deleteObjects:[MomoMapDataSet allObjects]];
        [realm deleteObjects:[MomoPinDataSet allObjects]];
        [realm deleteObjects:[MomoPostDataSet allObjects]];
        
        // Map 데이터 파싱 및 저장(업데이트)
        for (NSDictionary *mapDic in ((NSArray *)[responseDic objectForKey:@"map_list"])) {
            MomoMapDataSet *mapData = [MomoMapDataSet makeMapWithDic:mapDic];
            
            [realm addOrUpdateObject:mapData];              // map 데이터 add or update
            [[DataCenter myMapList] addObject:mapData];     // 싱글턴 객체 UserData 프로퍼티 map_list에 지도 추가
            
            
            // Pin 데이터 파싱 및 저장(업데이트)
            for (NSDictionary *pinDic in ((NSArray *)[mapDic objectForKey:@"pin_list"])) {
                MomoPinDataSet *pinData = [MomoPinDataSet makePinWithDic:pinDic];
                
                [realm addOrUpdateObject:pinData];              // pin 데이터 add or update
                [mapData.map_pin_list addObject:pinData];       // map의 pin_list에 pin 추가
                
                
                // Post 데이터 파싱 및 저장(업데이트)
                for (NSDictionary *postDic in ((NSArray *)[pinDic objectForKey:@"post_list"])) {
                    MomoPostDataSet *postData = [MomoPostDataSet makePostWithDic:postDic];
                    
                    [realm addOrUpdateObject:postData];             // post 데이터 add or update
                    [pinData.pin_post_list addObject:postData];     // pin의 post_list에 post 추가
                }
            }
        }
    }];
}

@end


