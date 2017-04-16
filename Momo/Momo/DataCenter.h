//
//  DataCenter.h
//  Momo
//
//  Created by Jeheon Choi on 2017. 3. 27..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MomoUserDataSet;

@interface DataCenter : NSObject

// 싱글턴 객체 호출 메소드
+ (instancetype)sharedInstance;


// MOMO Dataset 관련 -----------------------------------//
#pragma mark - MOMO Dataset 관련
@property (nonatomic) MomoUserDataSet *momoUserData;    // Map, Pin, Post 전부 포함
+ (RLMArray<MomoMapDataSet *> *)myMapList;
+ (RLMArray<MomoPinDataSet *> *)myPinListWithMapIndex:(NSInteger)mapIndex;
+ (RLMArray<MomoPostDataSet *> *)myPostListWithMapIndex:(NSInteger)mapIndex WithPinIndex:(NSInteger)pinIndex;


// Account Token 자동로그인 ------------------------------//
#pragma mark - Auto Login / Token getter
- (NSString *)getUserToken;


// User Data 저장, 불러오기, 삭제 --------------------------//
#pragma mark - MOMO User Data 저장, 패치, 삭제
+ (void)initialSaveMomoUserData;   // 초기 저장
- (BOOL)fetchMomoUserData;  // 패치
+ (void)removeMomoUserData; // 삭제


@end
