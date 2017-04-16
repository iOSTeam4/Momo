//
//  MomoDataSet.h
//  Momo
//
//  Created by Jeheon Choi on 2017. 4. 10..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import <Realm/Realm.h>

RLM_ARRAY_TYPE(MomoPlaceDataSet)
RLM_ARRAY_TYPE(MomoPostDataSet)
RLM_ARRAY_TYPE(MomoPinDataSet)
RLM_ARRAY_TYPE(MomoMapDataSet)
RLM_ARRAY_TYPE(MomoUserDataSet)


// Place Data Set ---------------------------//
@interface MomoPlaceDataSet : RLMObject
@property NSInteger pk;

// place_<key>
@property NSString *place_name;
@property NSString *place_id;
@property NSString *place_address;

@property CGFloat place_lat;      // latitude
@property CGFloat place_lng;      // longitude

@end


// Post Data Set ---------------------------//
@interface MomoPostDataSet : RLMObject
@property NSInteger pk;

// post_<key>
@property NSString *post_pin_name;
@property NSString *post_pin_address;

@property NSData *post_image_data;
@property NSString *post_comments;

@property NSString *post_created_date;

- (UIImage *)getPostImage;

@end


// Pin Data Set -----------------------------//
@interface MomoPinDataSet : RLMObject
@property NSInteger pk;

// pin_<key>
@property NSString *pin_author;
@property MomoPlaceDataSet *pin_place;

@property NSString *pin_name;
@property NSInteger pin_label;
@property NSString *pin_map;

@property NSString *pin_created_date;

@property RLMArray<MomoPostDataSet *><MomoPostDataSet> *pin_post_list;

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
@property BOOL map_is_private;

@property NSString *map_author;
@property NSString *map_created_date;

@property RLMArray<MomoPinDataSet *><MomoPinDataSet> *map_pin_list;

@end


// User Data Set ----------------------------//
@interface MomoUserDataSet : RLMObject
@property NSInteger pk;

// user_<key>
@property NSString *user_token;
@property NSString *user_fb_token;

@property NSString *user_id;
@property NSString *user_username;
@property NSData *user_profile_image_data;
@property NSString *user_profile_image_url;
@property NSString *user_email;


@property RLMArray<MomoUserDataSet *><MomoUserDataSet> *user_follower_list;
@property RLMArray<MomoUserDataSet *><MomoUserDataSet> *user_following_list;

@property RLMArray<MomoMapDataSet *><MomoMapDataSet> *user_map_list;

- (UIImage *)getUserProfileImage;

@end



