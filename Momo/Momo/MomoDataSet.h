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
//@property (nonatomic) NSInteger *pk;

// place_<key>
@property (nonatomic) NSString *place_name;
@property (nonatomic) NSString *place_id;
@property (nonatomic) NSString *place_address;

@property (nonatomic) CGFloat place_lat;      // latitude
@property (nonatomic) CGFloat place_lng;      // longitude

@end


// Post Data Set ---------------------------//
@interface MomoPostDataSet : RLMObject
//@property (nonatomic) NSInteger *pk;

// post_<key>
@property (nonatomic) NSString *post_pin_name;
@property (nonatomic) NSString *post_pin_address;

@property (nonatomic) NSData *post_image_data;
@property (nonatomic) NSString *post_comments;

@property (nonatomic) NSString *post_created_date;

- (UIImage *)getPostImage;

@end


// Pin Data Set -----------------------------//
@interface MomoPinDataSet : RLMObject
//@property (nonatomic) NSInteger *pk;

// pin_<key>
@property (nonatomic) NSString *pin_author;
@property (nonatomic) MomoPlaceDataSet *pin_place;

@property (nonatomic) NSString *pin_name;
@property (nonatomic) NSInteger pin_label;
@property (nonatomic) NSString *pin_map;

@property (nonatomic) NSString *pin_created_date;

@property (nonatomic) RLMArray<MomoPostDataSet *><MomoPostDataSet> *pin_post_list;

// 핀 라벨 아이콘, 색 반환 메서드
- (UIImage *)labelIcon;
- (UIColor *)labelColor;

@end




// Map Data Set -----------------------------//
@interface MomoMapDataSet : RLMObject
//@property (nonatomic) NSInteger *pk;

// map_<key>
@property (nonatomic) NSString *map_name;
@property (nonatomic) NSString *map_description;
@property (nonatomic) BOOL map_is_private;

@property (nonatomic) NSString *map_author;
@property (nonatomic) NSString *map_created_date;

@property (nonatomic) RLMArray<MomoPinDataSet *><MomoPinDataSet> *map_pin_list;

@end


// User Data Set ----------------------------//
@interface MomoUserDataSet : RLMObject
//@property (nonatomic) NSInteger *pk;

// user_<key>
@property (nonatomic) NSString *user_token;

@property (nonatomic) NSString *user_id;
@property (nonatomic) NSString *user_username;
@property (nonatomic) NSData *user_profile_image_data;
@property (nonatomic) NSString *user_profile_image_url;
@property (nonatomic) NSString *user_email;


@property (nonatomic) RLMArray<MomoUserDataSet *><MomoUserDataSet> *user_follower_list;
@property (nonatomic) RLMArray<MomoUserDataSet *><MomoUserDataSet> *user_following_list;

@property (nonatomic) RLMArray<MomoMapDataSet *><MomoMapDataSet> *user_map_list;

- (UIImage *)getUserProfileImage;

@end



