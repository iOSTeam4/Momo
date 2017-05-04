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
        data.realm = [RLMRealm defaultRealm];       // Set Singleton Realm Object
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

#pragma mark - MOMO Data property

- (NSString *)getUserToken {
    // Token 없으면 nil
    return [DataCenter sharedInstance].momoUserData.user_token;
}





#pragma mark - MOMO User Data 저장, 확인, 수정

// 유저 전체 데이터 파싱 및 저장
+ (void)setMomoUserDataWithResponseDic:(NSDictionary *)responseDic {
    
    // realm transaction
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
        
        // User 정보
        [DataCenter sharedInstance].momoUserData = [MomoUserDataSet parseUserDic:responseDic withProfileImgData:nil];
        [[DataCenter myMapList] removeAllObjects];          // user_map_list 초기화
        
        [realm addOrUpdateObject:[DataCenter sharedInstance].momoUserData];     // userData add or update
        
        // Map 데이터 파싱 및 저장(업데이트)
        for (NSDictionary *mapDic in ((NSArray *)[responseDic objectForKey:@"map_list"])) {
            
            MomoMapDataSet *mapData = [MomoMapDataSet parseMapDic:mapDic];
            [mapData.map_pin_list removeAllObjects];        // map_pin_list 초기화
            
            [realm addOrUpdateObject:mapData];              // mapData add or update
            [[DataCenter myMapList] insertObject:mapData atIndex:0];     // 싱글턴 객체 UserData 프로퍼티 map_list에 지도 추가
            
            
            // Pin 데이터 파싱 및 저장(업데이트)
            for (NSDictionary *pinDic in ((NSArray *)[mapDic objectForKey:@"pin_list"])) {
                
                MomoPinDataSet *pinData = [MomoPinDataSet parsePinDic:pinDic];
                [pinData.pin_post_list removeAllObjects];       // pin_post_list 초기화
                
                [realm addOrUpdateObject:pinData];              // pinData add or update
                [mapData.map_pin_list insertObject:pinData atIndex:0];       // map의 pin_list에 pin 추가
                
                
                // Post 데이터 파싱 및 저장(업데이트)
                for (NSDictionary *postDic in ((NSArray *)[pinDic objectForKey:@"post_list"])) {
                    
                    MomoPostDataSet *postData = [MomoPostDataSet parsePostDic:postDic withPhotoData:nil];
                    
                    [realm addOrUpdateObject:postData];             // postData add or update
                    [pinData.pin_post_list insertObject:postData atIndex:0];     // pin의 post_list에 post 추가
                }
            }
        }
    }];
}



// 유저 데이터 확인
- (void)checkUserDataWithCompletionBlock:(void (^)(BOOL isSuccess))completionBlock {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    // 기존 저장되어있던 기본 데이터들 확인 (페북 & 이메일 공통)
    if([MomoLoginDataSet allObjectsInRealm:realm].count > 0) {     // nil이 아닐 때 불러옴
        [DataCenter sharedInstance].momoLoginData = [MomoLoginDataSet allObjectsInRealm:realm].firstObject;     // 로그인 데이터는 하나만 있음
        
        NSLog(@"token : %@, loginData cnt : %ld, userData cnt : %ld", [DataCenter sharedInstance].momoLoginData.token, [MomoLoginDataSet allObjectsInRealm:realm].count, [MomoUserDataSet allObjects].count);
        
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



// 유저 수정 (+ with imgData)
+ (void)updateUserWithUserDic:(NSDictionary *)userDic withProfileImgData:(NSData *)imgData {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
        
        MomoUserDataSet *userData = [MomoUserDataSet parseUserDic:userDic withProfileImgData:imgData];
        
        // 유저 정보 업데이트
        [realm addOrUpdateObject:userData];
    }];
}






#pragma mark - MOMO Map
// 맵 생성
+ (void)createMapWithMapDic:(NSDictionary *)mapDic {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{

        MomoMapDataSet *mapData = [MomoMapDataSet parseMapDic:mapDic];
    
        [realm addOrUpdateObject:mapData];
        [[DataCenter myMapList] insertObject:mapData atIndex:0];
    }];
}

// 맵 수정
+ (void)updateMapWithMapDic:(NSDictionary *)mapDic {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{

        MomoMapDataSet *mapData = [MomoMapDataSet parseMapDic:mapDic];
    
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
+ (void)createPinWithPinDic:(NSDictionary *)pinDic {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{

        MomoPinDataSet *pinData = [MomoPinDataSet parsePinDic:pinDic];
    
        [realm addOrUpdateObject:pinData];
        
        MomoMapDataSet *mapData = [DataCenter findMapDataWithMapPK:pinData.pin_map_pk];
        [mapData.map_pin_list insertObject:pinData atIndex:0];
    }];
}

// 핀 수정
+ (void)updatePinWithPinDic:(NSDictionary *)pinDic {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
        
        MomoPinDataSet *pinData = [MomoPinDataSet parsePinDic:pinDic];
        
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
        [mapData.map_pin_list insertObject:pinData atIndex:0];       // 현재 속한 지도에 등록
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
+ (void)createPostWithPostDic:(NSDictionary *)postDic withPhotoData:(NSData *)photoData {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
        
        MomoPostDataSet *postData = [MomoPostDataSet parsePostDic:postDic withPhotoData:photoData];
        
        [realm addOrUpdateObject:postData];
        
        MomoPinDataSet *pinData = [DataCenter findPinDataWithPinPK:postData.post_pin_pk];
        [pinData.pin_post_list insertObject:postData atIndex:0];
    }];
}

// 포스트 수정
+ (void)updatePostWithPostDic:(NSDictionary *)postDic withPhotoData:(NSData *)photoData {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
        
        MomoPostDataSet *postData = [MomoPostDataSet parsePostDic:postDic withPhotoData:photoData];
        
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

+ (RLMArray<MomoPinDataSet *> *)myPinList {
    return (RLMArray<MomoPinDataSet *> *)[[MomoPinDataSet objectsWhere:[NSString stringWithFormat:@"pin_author.pk == %ld", [DataCenter sharedInstance].momoUserData.pk]] sortedResultsUsingKeyPath:@"pk" ascending:NO];
}

+ (RLMArray<MomoPinDataSet *> *)myPinListWithMapPK:(NSInteger)mapPK {
    return [DataCenter findMapDataWithMapPK:mapPK].map_pin_list;
}


+ (RLMArray<MomoPostDataSet *> *)myPostListWithMapPK:(NSInteger)mapPK {
    MomoPinDataSet *tempPinData = [[MomoPinDataSet alloc] init];

    for (MomoPinDataSet *pinData in [DataCenter findMapDataWithMapPK:mapPK].map_pin_list) {
        [tempPinData.pin_post_list addObjects:pinData.pin_post_list];
    }
        
    return tempPinData.pin_post_list;
}


+ (RLMArray<MomoPostDataSet *> *)myPostListWithPinPK:(NSInteger)pinPK {
    return [DataCenter findPinDataWithPinPK:pinPK].pin_post_list;
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


