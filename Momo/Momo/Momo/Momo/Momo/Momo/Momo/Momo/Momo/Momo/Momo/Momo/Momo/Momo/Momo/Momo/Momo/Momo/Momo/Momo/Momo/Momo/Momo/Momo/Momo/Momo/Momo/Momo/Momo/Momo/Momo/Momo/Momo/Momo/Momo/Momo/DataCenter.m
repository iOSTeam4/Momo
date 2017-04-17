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
- (BOOL)fetchMomoUserData {
    
    // 기존 저장되어있던 기본 데이터들 패치 (페북 & 이메일 공통)
    if([MomoUserDataSet allObjects].firstObject) {     // nil이 아닐 때 불러옴
        [DataCenter sharedInstance].momoUserData = [MomoUserDataSet allObjectsInRealm:[RLMRealm defaultRealm]].firstObject;    // 첫번째 UserData가 내 계정

        NSLog(@"token : %@, count : %ld =? %ld", [DataCenter sharedInstance].momoUserData.user_token, [MomoUserDataSet allObjectsInRealm:[RLMRealm defaultRealm]].count, [MomoUserDataSet allObjects].count);
        
        // 서버랑 변동사항 없나 확인 절차 필요
        
        return YES;
        
    } else {    // 토큰 없을 때
        [DataCenter sharedInstance].momoUserData = [[MomoUserDataSet alloc] init];
        
        return NO;
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



@end


