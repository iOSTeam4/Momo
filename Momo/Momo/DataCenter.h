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

+ (MomoMapDataSet *)findMapDataWithMapPK:(NSInteger)map_pk;
+ (MomoPinDataSet *)findPinDataWithPinPK:(NSInteger)pin_pk;
+ (MomoPostDataSet *)findPostDataWithPostPK:(NSInteger)post_pk;


// Account Token 자동로그인 ------------------------------//
#pragma mark - Auto Login / Token getter
- (NSString *)getUserToken;


// User Data 저장, 불러오기, 삭제 --------------------------//
#pragma mark - MOMO User Data 저장, 패치, 삭제
+ (void)momoGetMemberProfileDicParsingAndUpdate:(NSDictionary *)responseDic;
+ (void)initialSaveMomoUserData;   // 초기 저장
- (void)fetchMomoUserDataWithCompletionBlock:(void (^)(BOOL isSuccess))completionBlock;  // 패치
+ (void)removeMomoUserData; // 삭제

#pragma mark - MOMO Map
+ (void)createMapWithMomoMapCreateDic:(NSDictionary *)mapDic;   // 맵 생성
+ (void)updateMapWithMomoMapCreateDic:(NSDictionary *)mapDic;   // 맵 수정
+ (void)deleteMapData:(MomoMapDataSet *)mapData;                // 맵 삭제


#pragma mark - MOMO Pin
+ (void)createPinWithMomoPinCreateDic:(NSDictionary *)pinDic;   // 핀 생성
+ (void)updatePinWithMomoPinCreateDic:(NSDictionary *)pinDic;   // 핀 수정
+ (void)deletePinData:(MomoPinDataSet *)pinData;                // 핀 삭제


#pragma mark - MOMO Post
+ (void)createPostWithMomoPostCreateDic:(NSDictionary *)postDic;    // 포스트 생성
+ (void)updatePostWithMomoPostCreateDic:(NSDictionary *)postDic;    // 포스트 수정
+ (void)deletePostData:(MomoPostDataSet *)postData;                 // 포스트 삭제
    


@end
