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
+ (instancetype)sharedInstance;         // DataCenter
@property RLMRealm *realm;              // Realm


// Account Token 자동로그인 ------------------------------//
#pragma mark - Auto Login / Token getter
@property (nonatomic) MomoLoginDataSet *momoLoginData;

+ (void)setLoginDataWithPK:(NSInteger)pk withToken:(NSString *)token;       // 로그인 정보 저장
+ (void)removeMomoLoginData;                                                // 로그인 정보 삭제


// MOMO Dataset 관련 -----------------------------------//
#pragma mark - MOMO Data property
@property (nonatomic) MomoUserDataSet *momoUserData;    // Map, Pin, Post 전부 포함
- (NSString *)getUserToken;

#pragma mark - MOMO User
+ (void)setMomoUserDataWithResponseDic:(NSDictionary *)responseDic;                             // 유저 전체 데이터 Dic 파싱하고 저장(업데이트)
- (void)checkUserDataWithCompletionBlock:(void (^)(BOOL isSuccess))completionBlock;             // 유저 데이터 확인

+ (void)updateUserWithUserDic:(NSDictionary *)userDic withProfileImgData:(NSData *)imgData;     // 유저 수정 (+ with imgData)


#pragma mark - MOMO Map
+ (void)createMapWithMapDic:(NSDictionary *)mapDic;     // 맵 생성
+ (void)updateMapWithMapDic:(NSDictionary *)mapDic;     // 맵 수정
+ (void)deleteMapData:(MomoMapDataSet *)mapData;        // 맵 삭제

#pragma mark - MOMO Pin
+ (void)createPinWithPinDic:(NSDictionary *)pinDic;     // 핀 생성
+ (void)updatePinWithPinDic:(NSDictionary *)pinDic;     // 핀 수정
+ (void)deletePinData:(MomoPinDataSet *)pinData;        // 핀 삭제

#pragma mark - MOMO Post
+ (void)createPostWithPostDic:(NSDictionary *)postDic withPhotoData:(NSData *)photoData;    // 포스트 생성 (+ with photoData)
+ (void)updatePostWithPostDic:(NSDictionary *)postDic withPhotoData:(NSData *)photoData;    // 포스트 수정 (+ with photoData)
+ (void)deletePostData:(MomoPostDataSet *)postData;                                         // 포스트 삭제



#pragma mark - MOMO Data List
+ (RLMArray<MomoMapDataSet *> *)myMapList;                                  // Map  List
+ (RLMArray<MomoPinDataSet *> *)myPinList;                                  // Pin  List
+ (RLMArray<MomoPinDataSet *> *)myPinListWithMapPK:(NSInteger)mapPK;        // Pin  List (with mapPK)
+ (RLMArray<MomoPostDataSet *> *)myPostListWithMapPK:(NSInteger)mapPK;      // Post List (with mapPK)
+ (RLMArray<MomoPostDataSet *> *)myPostListWithPinPK:(NSInteger)pinPK;      // Post List (with pinPK)

#pragma mark - MOMO Data Find
+ (MomoUserDataSet *)findUserDataWithUserPK:(NSInteger)user_pk;     // user pk로 user 데이터 객체 찾기
+ (MomoMapDataSet *)findMapDataWithMapPK:(NSInteger)map_pk;         // map  pk로 map  데이터 객체 찾기
+ (MomoPinDataSet *)findPinDataWithPinPK:(NSInteger)pin_pk;         // pin  pk로 pin  데이터 객체 찾기
+ (MomoPostDataSet *)findPostDataWithPostPK:(NSInteger)post_pk;     // post pk로 post 데이터 객체 찾기


@end
