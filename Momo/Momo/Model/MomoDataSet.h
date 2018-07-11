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
@class MomoLoginDataSet;

RLM_ARRAY_TYPE(MomoPlaceDataSet)
RLM_ARRAY_TYPE(MomoPostDataSet)
RLM_ARRAY_TYPE(MomoPinDataSet)
RLM_ARRAY_TYPE(MomoMapDataSet)
RLM_ARRAY_TYPE(MomoUserDataSet)
RLM_ARRAY_TYPE(MomoLoginDataSet)


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
- (UIImage *)getPostPhoto;
- (UIImage *)getPostPhotoThumbnail;

// description
@property NSString *post_description;

@property NSString *post_created_date;


// 포스트 생성, Momo 서버로부터 받아온 Dic으로 객체 생성, 반환   (with PhotoData)
+ (MomoPostDataSet *)parsePostDic:(NSDictionary *)postDic withPhotoData:(NSData *)photoData;


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

///////////////
@property NSString *pin_description;
///////////////

// Momo 서버로부터 받아온 Dic으로 Pin 객체 세팅(생성 or 업데이트) & 반환
+ (MomoPinDataSet *)parsePinDic:(NSDictionary *)pinDic;

// 핀 라벨 아이콘, 색 반환 메서드
- (UIImage *)labelIcon;
- (UIColor *)labelColor;

@end




// Map Data Set -----------------------------//
@interface MomoMapDataSet : RLMObject
@property NSInteger pk;

// map_<key>
@property NSString *map_name;
@property NSString *map_description;
@property NSString *map_created_date;
@property BOOL map_is_private;

@property MomoAuthorDataSet *map_author;

@property RLMArray<MomoPinDataSet *><MomoPinDataSet> *map_pin_list;

// Momo 서버로부터 받아온 MapDic으로 Map 객체 세팅(생성 or 업데이트) & 반환
+ (MomoMapDataSet *)parseMapDic:(NSDictionary *)mapDic;

@end


// User Data Set ----------------------------//
@interface MomoUserDataSet : RLMObject
@property NSInteger pk;

// user_<key>
@property NSString *user_token;
@property NSString *user_fb_token;

@property MomoAuthorDataSet *user_author;       // username, img
@property NSString *user_email;

@property RLMArray<MomoUserDataSet *><MomoUserDataSet> *user_follower_list;
@property RLMArray<MomoUserDataSet *><MomoUserDataSet> *user_following_list;

@property RLMArray<MomoMapDataSet *><MomoMapDataSet> *user_map_list;

@property NSString *user_id;
@property NSString *user_description;

// Momo 서버로부터 받아온 UserDic으로 User객체 세팅(생성 or 업데이트) & 반환      (+ with imgData)
+ (MomoUserDataSet *)parseUserDic:(NSDictionary *)userDic withProfileImgData:(NSData *)imgData;

@end



// Log in Data Set --------------------------//
@interface MomoLoginDataSet : RLMObject

@property NSInteger pk;
@property NSString *token;

@end



