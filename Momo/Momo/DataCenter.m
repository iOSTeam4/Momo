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



// Account Token 자동로그인 ------------------------------//
#pragma mark - Auto Login / Token getter


// 로그인 정보 저장
+ (void)setLoginDataWithPK:(NSInteger)pk withToken:(NSString *)token {
    
    [DataCenter sharedInstance].momoLoginData = [[MomoLoginDataSet alloc] init];
    [DataCenter sharedInstance].momoLoginData.pk = pk;
    [DataCenter sharedInstance].momoLoginData.token = token;
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
        [realm addObject:[DataCenter sharedInstance].momoLoginData];
    }];
    
}

// 로그인 정보 삭제
+ (void)removeMomoLoginData {    
    NSLog(@"user_pk : %ld", [DataCenter sharedInstance].momoLoginData.pk);
    NSLog(@"user_token : %@", [DataCenter sharedInstance].momoLoginData.token);
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
        [realm deleteObject:[DataCenter sharedInstance].momoLoginData];
    }];
}




// MOMO Dataset 관련 -----------------------------------//


#pragma mark - MOMO User Data 저장, 패치

- (NSString *)getUserToken {
    // Token 없으면 nil
    return [DataCenter sharedInstance].momoUserData.user_token;
}


// 패치
- (void)fetchMomoUserDataWithCompletionBlock:(void (^)(BOOL isSuccess))completionBlock {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    // 기존 저장되어있던 기본 데이터들 패치 (페북 & 이메일 공통)
    if([MomoLoginDataSet allObjectsInRealm:realm].firstObject) {     // nil이 아닐 때 불러옴
        [DataCenter sharedInstance].momoLoginData = [MomoLoginDataSet allObjectsInRealm:realm].firstObject;     // 로그인 데이터는 하나만 있음

        NSLog(@"token : %@, login cnt : %ld, user cnt : %ld", [DataCenter sharedInstance].momoLoginData.token, [MomoLoginDataSet allObjectsInRealm:realm].count, [MomoUserDataSet allObjects].count);
        
        [NetworkModule getMemberProfileRequestWithCompletionBlock:^(BOOL isSuccess, NSString *result) {
            
            if (isSuccess) {
                NSLog(@"get Member Profile Request success : %@", result);

                completionBlock(YES);
                
            } else {
                NSLog(@"get Member Profile Request error : %@", result);
                [DataCenter removeMomoLoginData];
                
                completionBlock(NO);
            }
        }];
        
    } else {    // 토큰 없을 때
        [DataCenter sharedInstance].momoUserData = [[MomoUserDataSet alloc] init];
        
        completionBlock(NO);
    }
}


// 유저 전체 데이터 파싱 및 저장
+ (void)setMomoUserDataWithResponseDic:(NSDictionary *)responseDic {
    
    // realm transaction
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
    
        // User 정보
        [DataCenter sharedInstance].momoUserData = [MomoUserDataSet makeUserWithDic:responseDic];   // 캐싱 정보 사용 or 새로 만들어 realm에 add
        [realm addOrUpdateObject:[DataCenter sharedInstance].momoUserData];
        
        
        // Map 데이터 파싱 및 저장(업데이트)
        for (NSDictionary *mapDic in ((NSArray *)[responseDic objectForKey:@"map_list"])) {

            MomoMapDataSet *mapData = [MomoMapDataSet makeMapWithDic:mapDic];                       // 캐싱 정보 사용 or 새로 만들어 realm에 add
            [realm addOrUpdateObject:mapData];
            mapData.map_pin_list = nil;     // 핀 리스트 초기화
            
            [[DataCenter myMapList] addObject:mapData];    // 싱글턴 객체 UserData 프로퍼티 map_list에 지도 추가
            
            
            // Pin 데이터 파싱 및 저장(업데이트)
            for (NSDictionary *pinDic in ((NSArray *)[mapDic objectForKey:@"pin_list"])) {

                MomoPinDataSet *pinData = [MomoPinDataSet makePinWithDic:pinDic];                   // 캐싱 정보 사용 or 새로 만들어 realm에 add
                [realm addOrUpdateObject:pinData];
                pinData.pin_post_list = nil;        // 포스트 리스트 초기화
                
                // 재로그인시 아래와 같은 에러 발생.. 이해안됨..
                // Terminating app due to uncaught exception 'RLMException', reason: 'Index 0 is out of bounds (must be less than 0)'
                [mapData.map_pin_list addObject:pinData];       // map의 pin_list에 pin 추가
                
                
                // Post 데이터 파싱 및 저장(업데이트)
                for (NSDictionary *postDic in ((NSArray *)[pinDic objectForKey:@"post_list"])) {
                    
                    MomoPostDataSet *postData = [MomoPostDataSet makePostWithDic:postDic];          // 캐싱 정보 사용 or 새로 만들어 realm에 add
                    [realm addOrUpdateObject:postData];
                    
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
        
        // 핀 정보 업데이트
        [realm addOrUpdateObject:pinData];
        
        // 속한 지도를 변경했을 때
        for (MomoMapDataSet *mapData in [DataCenter myMapList]) {
            if ([mapData.map_pin_list objectsWhere:[NSString stringWithFormat:@"pk==%ld", pinData.pk]].count > 0) {
            
                [mapData.map_pin_list removeObjectAtIndex:[mapData.map_pin_list indexOfObject:pinData]];    // 이전에 속했던 map의 pin_list에서 핀 제거
                
                break;      // 단, 하나임 그래서 break
            }
        }
    
        MomoMapDataSet *mapData = [DataCenter findMapDataWithMapPK:pinData.pin_map_pk];
        [mapData.map_pin_list addObject:pinData];       // 현재 속한 지도에 등록
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



#pragma mark - MOMO Data List

+ (RLMArray<MomoMapDataSet *> *)myMapList {
    return [DataCenter sharedInstance].momoUserData.user_map_list;
}

+ (RLMArray<MomoPinDataSet *> *)myPinListWithMapIndex:(NSInteger)mapIndex {
    return [DataCenter myMapList][mapIndex].map_pin_list;
}

+ (RLMArray<MomoPostDataSet *> *)myPostListWithMapIndex:(NSInteger)mapIndex WithPinIndex:(NSInteger)pinIndex {
    return [DataCenter myPinListWithMapIndex:mapIndex][pinIndex].pin_post_list;
}


#pragma mark - MOMO Data Find

+ (MomoUserDataSet *)findUserDataWithUserPK:(NSInteger)user_pk {
    if ([MomoUserDataSet objectsWhere:[NSString stringWithFormat:@"pk==%ld", user_pk]].count > 0) {
        return [MomoUserDataSet objectsWhere:[NSString stringWithFormat:@"pk==%ld", user_pk]][0];
    } else {
        return nil;
    }
}


+ (MomoMapDataSet *)findMapDataWithMapPK:(NSInteger)map_pk {
    if ([MomoMapDataSet objectsWhere:[NSString stringWithFormat:@"pk==%ld", map_pk]].count > 0) {
        return [MomoMapDataSet objectsWhere:[NSString stringWithFormat:@"pk==%ld", map_pk]][0];
    } else {
        return nil;
    }
}

+ (MomoPinDataSet *)findPinDataWithPinPK:(NSInteger)pin_pk {
    if ([MomoPinDataSet objectsWhere:[NSString stringWithFormat:@"pk==%ld", pin_pk]].count > 0) {
        return [MomoPinDataSet objectsWhere:[NSString stringWithFormat:@"pk==%ld", pin_pk]][0];
    } else {
        return nil;
    }
}

+ (MomoPostDataSet *)findPostDataWithPostPK:(NSInteger)post_pk {
    if ([MomoPostDataSet objectsWhere:[NSString stringWithFormat:@"pk==%ld", post_pk]].count > 0) {
        return [MomoPostDataSet objectsWhere:[NSString stringWithFormat:@"pk==%ld", post_pk]][0];
    } else {
        return nil;
    }
}



@end


