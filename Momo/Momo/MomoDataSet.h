//
//  MomoDataSet.h
//  Momo
//
//  Created by Jeheon Choi on 2017. 4. 10..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import <Realm/Realm.h>

@class MomoAuthorDataSet;
@class MomoPlaceDataSet;
@class MomoPostDataSet;
@class MomoPinDataSet;
@class MomoMapDataSet;
@class MomoUserDataSet;

RLM_ARRAY_TYPE(MomoPlaceDataSet)
RLM_ARRAY_TYPE(MomoPostDataSet)
RLM_ARRAY_TYPE(MomoPinDataSet)
RLM_ARRAY_TYPE(MomoMapDataSet)
RLM_ARRAY_TYPE(MomoUserDataSet)


// Author Data Set ---------------------------//
@interface MomoAuthorDataSet : RLMObject

@property NSInteger pk;
@property NSString *username;
@property (nonatomic) NSString *profile_img_url;
@property NSData *profile_img_data;

- (UIImage *)getAuthorProfileImg;

@end


// Place Data Set ---------------------------//
@interface MomoPlaceDataSet : RLMObject
@property NSInteger pk;

// place_<key>
@property NSString *place_name;
@property NSString *place_address;
@property NSString *place_googlepid;       //googlepid

@property CGFloat place_lat;      // latitude
@property CGFloat place_lng;      // longitude

@end


// Post Data Set ---------------------------//
@interface MomoPostDataSet : RLMObject
@property NSInteger pk;

// post_<key>
@property NSInteger post_pin_pk;
@property MomoAuthorDataSet *post_author;

// photo
@property (nonatomic) NSString *post_photo_url;
@property (nonatomic) NSString *post_photo_thumbnail_url;
@property NSData *post_photo_data;
@property NSData *post_photo_thumbnail_data;


// 포스트 생성, Momo 서버로부터 받아온 Dic으로 객체 생성, 반환
+ (MomoPostDataSet *)makePostWithDic:(NSDictionary *)postDic;

- (UIImage *)getPostPhotoThumbnail;
- (UIImage *)getPostPhoto;

// description
@property NSString *post_description;

@property NSString *post_created_date;


@end


// Pin Data Set -----------------------------//
@interface MomoPinDataSet : RLMObject
@property NSInteger pk;

// pin_<key>
@property NSInteger pin_map_pk;
@property NSString *pin_name;
@property NSInteger pin_label;
@property NSString *pin_created_date;

@property MomoAuthorDataSet *pin_author;

@property MomoPlaceDataSet *pin_place;
@property RLMArray<MomoPostDataSet *><MomoPostDataSet> *pin_post_list;

/////////////////
//@property NSString *pin_description;
/////////////////

// 핀 생성, Momo 서버로부터 받아온 Dic으로 객체 생성, 반환
+ (MomoPinDataSet *)makePinWithDic:(NSDictionary *)pinDic;

// 핀 생성 및 등록
+ (MomoPinDataSet *)makePinWithName:(NSString *)pinName
                       withPinLabel:(NSInteger)pinLabel
                            withMap:(NSInteger)mapIndex;

// 핀 라벨 아이콘, 색 반환 메서드
- (UIImage *)labelIcon;
- (UIColor *)labelColor;

@end




// Map Data Set -----------------------------//
@interface MomoMapDataSet : RLMObject
@property NSInteger pk;     // id

// map_<key>
@property NSString *map_name;
@property NSString *map_description;
@property NSString *map_created_date;
@property BOOL map_is_private;

@property MomoAuthorDataSet *map_author;

@property RLMArray<MomoPinDataSet *><MomoPinDataSet> *map_pin_list;

// 맵 생성, Momo 서버로부터 받아온 Dic으로 객체 생성, 반환
+ (MomoMapDataSet *)makeMapWithDic:(NSDictionary *)mapDic;

// 맵 생성 및 등록
+ (MomoMapDataSet *)makeMapWithName:(NSString *)mapName
                 withMapDescription:(NSString *)mapDescription
                        withPrivate:(BOOL)isPrivate;

@end


// User Data Set ----------------------------//
@interface MomoUserDataSet : RLMObject
@property NSInteger pk;

// user_<key>
@property NSString *user_token;
@property NSString *user_fb_token;

@property NSString *user_username;

@property NSString *user_email;

@property (nonatomic) NSString *user_profile_image_url;
@property NSData *user_profile_image_data;
- (UIImage *)getUserProfileImage;


@property RLMArray<MomoUserDataSet *><MomoUserDataSet> *user_follower_list;
@property RLMArray<MomoUserDataSet *><MomoUserDataSet> *user_following_list;

@property RLMArray<MomoMapDataSet *><MomoMapDataSet> *user_map_list;


@end



