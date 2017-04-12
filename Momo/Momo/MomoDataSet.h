//
//  MomoDataSet.h
//  Momo
//
//  Created by Jeheon Choi on 2017. 4. 10..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MomoMapDataSet;
@class MomoPinDataSet;
@class MomoPostDataSet;
@class MomoPlaceDataSet;


// User Data Set ----------------------------//
@interface MomoUserDataSet : NSObject

// user_<key>
@property (nonatomic) NSString *user_token;

@property (nonatomic) NSString *user_id;
@property (nonatomic) NSString *user_username;
@property (nonatomic) UIImage *user_profile_image;
@property (nonatomic) NSString *user_profile_image_url;
@property (nonatomic) NSString *user_email;

@property (nonatomic) NSArray<MomoMapDataSet *> *user_map_list;

@property (nonatomic) NSArray<MomoUserDataSet *> *user_follower_list;
@property (nonatomic) NSArray<MomoUserDataSet *> *user_following_list;

@end




// Map Data Set -----------------------------//
@interface MomoMapDataSet : NSObject

// map_<key>
@property (nonatomic) NSString *map_name;
@property (nonatomic) NSString *map_description;
@property (nonatomic) BOOL map_is_private;

@property (nonatomic) NSDictionary *map_author;
@property (nonatomic) NSString *map_created_date;

@property (nonatomic) NSArray<MomoPinDataSet *> *map_pin_list;

@end


// Pin Data Set -----------------------------//
@interface MomoPinDataSet : NSObject

// pin_<key>
@property (nonatomic) NSDictionary *pin_author;
@property (nonatomic) MomoPlaceDataSet *pin_place;

@property (nonatomic) NSString *pin_name;
@property (nonatomic) NSInteger pin_label;
@property (nonatomic) NSString *pin_map;

@property (nonatomic) NSString *pin_created_date;

@property (nonatomic) NSArray<MomoPostDataSet *> *pin_post_list;

// 핀 라벨 아이콘, 색 반환 메서드
- (UIImage *)labelIcon;
- (UIColor *)labelColor;

@end


// Post Data Set ---------------------------//
@interface MomoPostDataSet : NSObject

// post_<key>
@property (nonatomic) NSString *post_pin_name;
@property (nonatomic) NSString *post_pin_address;

@property (nonatomic) UIImage *post_image;
@property (nonatomic) NSString *post_comments;

@property (nonatomic) NSString *post_created_date;

@end


// Place Data Set ---------------------------//
@interface MomoPlaceDataSet : NSObject

// place_<key>
@property (nonatomic) NSString *place_name;
@property (nonatomic) NSString *place_id;
@property (nonatomic) NSString *place_address;

@property (nonatomic) CGFloat place_lat;      // latitude
@property (nonatomic) CGFloat place_lng;      // longitude

@end




