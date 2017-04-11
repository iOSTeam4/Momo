//
//  MomoDataSet.h
//  Momo
//
//  Created by Jeheon Choi on 2017. 4. 10..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MapDataSet;
@class PinDataSet;
@class PostDataSet;


// User Data Set ----------------------------//
@interface MomoUserDataSet : NSObject

// user_<key>
@property (nonatomic) NSString *user_token;

@property (nonatomic) NSString *user_id;
@property (nonatomic) NSString *user_username;
@property (nonatomic) UIImage *user_profile_image;
@property (nonatomic) NSString *user_email;

@property (nonatomic) NSArray<MapDataSet *> *user_map_list;

@property (nonatomic) NSArray<MomoUserDataSet *> *user_follower_list;
@property (nonatomic) NSArray<MomoUserDataSet *> *user_following_list;

@end




// Map Data Set -----------------------------//
@interface MapDataSet : NSObject

// map_<key>
@property (nonatomic) NSString *map_name;
@property (nonatomic) NSString *map_description;
@property (nonatomic) BOOL *map_is_private;

@property (nonatomic) NSDictionary *map_author;
@property (nonatomic) NSString *map_created_date;

@property (nonatomic) NSArray<PinDataSet *> *map_pin_list;

@end


// Pin Data Set -----------------------------//
@interface PinDataSet : NSObject

// pin_<key>
@property (nonatomic) NSDictionary *pin_author;
@property (nonatomic) NSString *pin_place;

@property (nonatomic) NSString *pin_name;
@property (nonatomic) NSInteger pin_label;
@property (nonatomic) NSString *pin_map;

@property (nonatomic) NSString *pin_created_date;

@property (nonatomic) NSArray<PostDataSet *> *pin_post_list;

@end


// Post Data Set ---------------------------//
@interface PostDataSet : NSObject

// post_<key>
@property (nonatomic) NSString *post_pin_name;
@property (nonatomic) NSString *post_pin_address;

@property (nonatomic) UIImage *post_image;
@property (nonatomic) NSString *post_comments;

@property (nonatomic) NSString *post_created_date;

@end


// Place Data Set ---------------------------//
@interface PlaceDataSet : NSObject

// place_<key>
@property (nonatomic) NSString *place_name;
@property (nonatomic) NSString *place_id;
@property (nonatomic) NSString *place_address;

@property (nonatomic) NSString *place_lat;      // latitude
@property (nonatomic) NSString *place_lng;      // longitude

@end




