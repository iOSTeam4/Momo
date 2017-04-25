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


+ (MomoMapDataSet *)findMapDataWithMapPK:(NSInteger)map_pk {
    return [MomoMapDataSet objectsWhere:[NSString stringWithFormat:@"pk==%ld", map_pk]][0];
}

+ (MomoPinDataSet *)findPinDataWithPinPK:(NSInteger)pin_pk {
    return [MomoPinDataSet objectsWhere:[NSString stringWithFormat:@"pk==%ld", pin_pk]][0];
}

+ (MomoPostDataSet *)findPostDataWithPostPK:(NSInteger)post_pk {
    return [MomoPostDataSet objectsWhere:[NSString stringWithFormat:@"pk==%ld", post_pk]][0];
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


// 유저 전체 데이터 파싱 및 저장
+ (void)momoGetMemberProfileDicParsingAndUpdate:(NSDictionary *)responseDic {
        
    // realm transaction
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{

        // 추가 User 정보
        [DataCenter sharedInstance].momoUserData.user_username = [responseDic objectForKey:@"username"];
        [DataCenter sharedInstance].momoUserData.user_id = [responseDic objectForKey:@"userid"];
//        [DataCenter sharedInstance].momoUserData.user_description = [responseDic objectForKey:@"description"];    // String 값으로 바꿔 전달해달라해야함
        
        if ([responseDic objectForKey:@"email"]) {
            [DataCenter sharedInstance].momoUserData.user_email = [responseDic objectForKey:@"email"];
        }
        if ([[responseDic objectForKey:@"profile_img"] objectForKey:@"full_size"]) {
            [DataCenter sharedInstance].momoUserData.user_profile_image_url = [[responseDic objectForKey:@"profile_img"] objectForKey:@"full_size"];
            [DataCenter sharedInstance].momoUserData.user_profile_image_data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[responseDic objectForKey:@"profile_img"] objectForKey:@"full_size"]]];      // setter 왜 안불리지?
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


#pragma mark - MOMO Map
// 맵 생성
+ (void)createMapWithMomoMapCreateDic:(NSDictionary *)mapDic {
    
    MomoMapDataSet *mapData = [MomoMapDataSet makeMapWithDic:mapDic];
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
        [realm addOrUpdateObject:mapData];
        [[DataCenter myMapList] addObject:mapData];
    }];
}

// 맵 수정
+ (void)updateMapWithMomoMapCreateDic:(NSDictionary *)mapDic {
    
    MomoMapDataSet *mapData = [MomoMapDataSet makeMapWithDic:mapDic];
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
        [realm addOrUpdateObject:mapData];
    }];
}


// 맵 삭제
+ (void)deleteMapData:(MomoMapDataSet *)mapData {
    
    for (MomoPinDataSet *pinData in mapData.map_pin_list) {
        [DataCenter deletePinData:pinData];     // 지도 내부에 속한 핀들도 전부 삭제
    }
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
        [[DataCenter myMapList] removeObjectAtIndex:[[DataCenter myMapList] indexOfObject:mapData]];
        [realm deleteObject:mapData];
    }];
}


#pragma mark - MOMO Pin
// 핀 생성
+ (void)createPinWithMomoPinCreateDic:(NSDictionary *)pinDic {
    
    MomoPinDataSet *pinData = [MomoPinDataSet makePinWithDic:pinDic];
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
        [realm addOrUpdateObject:pinData];
        
        MomoMapDataSet *mapData = [DataCenter findMapDataWithMapPK:pinData.pin_map_pk];
        [mapData.map_pin_list addObject:pinData];
    }];
}

// 핀 수정
+ (void)updatePinWithMomoPinCreateDic:(NSDictionary *)pinDic {
    
    MomoPinDataSet *pinData = [MomoPinDataSet makePinWithDic:pinDic];
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
        // 이전에 속했던 map의 pin_list에서 핀 제거할 수 있게 세팅
        MomoPinDataSet *previousPinData = [DataCenter findPinDataWithPinPK:pinData.pk];
        MomoMapDataSet *previousMapData = [DataCenter findMapDataWithMapPK:previousPinData.pin_map_pk];
        NSInteger previousPinIndex = [previousMapData.map_pin_list indexOfObject:previousPinData];

        // 핀 정보 업데이트
        [realm addOrUpdateObject:pinData];
        
        // 속한 지도를 변경했을 때
        if (previousPinData.pin_map_pk != pinData.pin_map_pk) {
            // 이전에 속했던 map의 pin_list에서 핀 제거
            [previousMapData.map_pin_list removeObjectAtIndex:previousPinIndex];
            
            // 속한 맵의 pin_list에 핀 추가
            MomoMapDataSet *mapData = [DataCenter findMapDataWithMapPK:pinData.pin_map_pk];
            [mapData.map_pin_list addObject:pinData];
        }
        
    }];
}


// 핀 삭제
+ (void)deletePinData:(MomoPinDataSet *)pinData {
    
    for (MomoPostDataSet *postData in pinData.pin_post_list) {
        [DataCenter deletePostData:postData];     // 핀 내부에 속한 포스트들도 전부 삭제
    }
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
        MomoMapDataSet *mapData = [DataCenter findMapDataWithMapPK:pinData.pin_map_pk];                 // pin이 속한 map
        [mapData.map_pin_list removeObjectAtIndex:[mapData.map_pin_list indexOfObject:pinData]];        // map의 pin_list에서 삭제
        [realm deleteObject:pinData];
    }];
}



#pragma mark - MOMO Post
// 포스트 생성
+ (void)createPostWithMomoPostCreateDic:(NSDictionary *)postDic {
    
    MomoPostDataSet *postData = [MomoPostDataSet makePostWithDic:postDic];
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
        [realm addOrUpdateObject:postData];
        
        MomoPinDataSet *pinData = [DataCenter findPinDataWithPinPK:postData.post_pin_pk];
        [pinData.pin_post_list addObject:postData];
    }];
}

// 포스트 수정
+ (void)updatePostWithMomoPostCreateDic:(NSDictionary *)postDic {
    
    MomoPostDataSet *postData = [MomoPostDataSet makePostWithDic:postDic];
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
        // 포스트 정보 업데이트
        [realm addOrUpdateObject:postData];
    }];
}


// 포스트 삭제
+ (void)deletePostData:(MomoPostDataSet *)postData {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
        MomoPinDataSet *pinData = [DataCenter findPinDataWithPinPK:postData.post_pin_pk];                   // post가 속한 pin
        [pinData.pin_post_list removeObjectAtIndex:[pinData.pin_post_list indexOfObject:postData]];         // pin의 post_list에서 삭제
        [realm deleteObject:postData];
    }];
}




@end


