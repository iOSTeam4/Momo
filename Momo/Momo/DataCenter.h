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


// Account Token 자동로그인 ------------------------------//
#pragma mark - Auto Login / Token getter
@property (nonatomic) MomoLoginDataSet *momoLoginData;

+ (void)setLoginDataWithPK:(NSInteger)pk withToken:(NSString *)token;       // 로그인 정보 저장
+ (void)removeMomoLoginData;                                                // 로그인 정보 삭제


// MOMO Dataset 관련 -----------------------------------//
#pragma mark - MOMO Data property
@property (nonatomic) MomoUserDataSet *momoUserData;    // Map, Pin, Post 전부 포함
- (NSString *)getUserToken;

#pragma mark - MOMO User Data 저장, 패치
+ (void)setMomoUserDataWithResponseDic:(NSDictionary *)responseDic;                         // 유저 정보 Dic 파싱하고 저장(업데이트)
- (void)fetchMomoUserDataWithCompletionBlock:(void (^)(BOOL isSuccess))completionBlock;     // 패치

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


#pragma mark - MOMO Data List
+ (RLMArray<MomoMapDataSet *> *)myMapList;                                                                          // Map List
+ (RLMArray<MomoPinDataSet *> *)myPinListWithMapIndex:(NSInteger)mapIndex;                                          // Pin List
+ (RLMArray<MomoPostDataSet *> *)myPostListWithMapIndex:(NSInteger)mapIndex WithPinIndex:(NSInteger)pinIndex;       // Post List

#pragma mark - MOMO Data Find
+ (MomoUserDataSet *)findUserDataWithUserPK:(NSInteger)user_pk;     // user pk로 user 데이터 객체 찾기
+ (MomoMapDataSet *)findMapDataWithMapPK:(NSInteger)map_pk;         // map  pk로 map  데이터 객체 찾기
+ (MomoPinDataSet *)findPinDataWithPinPK:(NSInteger)pin_pk;         // pin  pk로 pin  데이터 객체 찾기
+ (MomoPostDataSet *)findPostDataWithPostPK:(NSInteger)post_pk;     // post pk로 post 데이터 객체 찾기


@end
