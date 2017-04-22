//
//  MomoDataSet.m
//  Momo
//
//  Created by Jeheon Choi on 2017. 4. 10..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import "MomoDataSet.h"

// Author Data Set ---------------------------//
@implementation MomoAuthorDataSet

+ (NSString *)primaryKey {
    return @"pk";
}

- (void)setProfile_img_url:(NSString *)profile_img_url {
    NSLog(@"setProfile_img_url setter %@", profile_img_url);
    
    if (profile_img_url) {       // nil이 아닐 때
        // url 설정하면서 자동으로 이미지 가져옴
        _profile_img_url = profile_img_url;
        self.profile_img_data = [NSData dataWithContentsOfURL:[NSURL URLWithString:profile_img_url]];
    }
}

- (UIImage *)getAuthorProfileImg {
    return [UIImage imageWithData:self.profile_img_data];
}


// Author 생성, Momo 서버로부터 받아온 Dic으로 객체 생성, 반환
+ (MomoAuthorDataSet *)makeAuthorWithDic:(NSDictionary *)authorDic {
    
    MomoAuthorDataSet *authorData = [[MomoAuthorDataSet alloc] init];
    
    authorData.pk = [[authorDic objectForKey:@"pk"] integerValue];
    authorData.username = [authorDic objectForKey:@"username"];
    authorData.profile_img_url = [[authorDic objectForKey:@"profile_img"] objectForKey:@"full_size"];
    
    return authorData;
}

@end


// Place Data Set ---------------------------//
@implementation MomoPlaceDataSet

+ (NSString *)primaryKey {
    return @"pk";
}


// Place 생성, Momo 서버로부터 받아온 Dic으로 객체 생성, 반환
+ (MomoPlaceDataSet *)makePlaceWithDic:(NSDictionary *)placeDic {
    
    MomoPlaceDataSet *placeData = [[MomoPlaceDataSet alloc] init];

    placeData.pk = [[placeDic objectForKey:@"pk"] integerValue];
    placeData.place_googlepid = [placeDic objectForKey:@"googlepid"];
    placeData.place_name = [placeDic objectForKey:@"name"];
    placeData.place_address = [placeDic objectForKey:@"address"];
    placeData.place_lat = [[placeDic objectForKey:@"lat"] doubleValue];
    placeData.place_lng = [[placeDic objectForKey:@"lng"] doubleValue];
    
    return placeData;
}

@end


// Post Data Set ---------------------------//
@implementation MomoPostDataSet

+ (NSString *)primaryKey {
    return @"pk";
}

+ (NSArray<NSString *> *)requiredProperties {
    return @[@"pk", @"post_pin_pk"];
}


// photo
- (void)setPost_photo_url:(NSString *)post_photo_url {
    NSLog(@"setPost_photo_url setter %@", post_photo_url);
    
    if (post_photo_url) {       // nil이 아닐 때
        // url 설정하면서 자동으로 이미지 가져옴
        _post_photo_url = post_photo_url;
        self.post_photo_data = [NSData dataWithContentsOfURL:[NSURL URLWithString:post_photo_url]];
    }
    
}

- (void)setPost_photo_thumbnail_url:(NSString *)post_photo_thumbnail_url {
    NSLog(@"setPost_photo_thumbnail_url setter %@", post_photo_thumbnail_url);
    
    if (post_photo_thumbnail_url) {       // nil이 아닐 때
        // url 설정하면서 자동으로 이미지 가져옴
        _post_photo_thumbnail_url = post_photo_thumbnail_url;
        self.post_photo_thumbnail_data = [NSData dataWithContentsOfURL:[NSURL URLWithString:post_photo_thumbnail_url]];
    }

}

- (UIImage *)getPostPhoto {
    return [UIImage imageWithData:self.post_photo_data];
}

- (UIImage *)getPostPhotoThumbnail {
    return [UIImage imageWithData:self.post_photo_thumbnail_data];
}




// 포스트 생성, Momo 서버로부터 받아온 Dic으로 객체 생성, 반환
+ (MomoPostDataSet *)makePostWithDic:(NSDictionary *)postDic {
    
    MomoPostDataSet *postData = [[MomoPostDataSet alloc] init];
    
    postData.pk = [[postDic objectForKey:@"pk"] integerValue];
    postData.post_pin_pk = [[postDic objectForKey:@"pin"] integerValue];
    postData.post_author = [MomoAuthorDataSet makeAuthorWithDic:[postDic objectForKey:@"author"]];
    
    postData.post_photo_url = [[postDic objectForKey:@"photo"] objectForKey:@"full_size"];
    postData.post_photo_url = [[postDic objectForKey:@"photo"] objectForKey:@"thumbnail"];
    
    postData.post_created_date = [postDic objectForKey:@"created_date"];
    postData.post_description = [postDic objectForKey:@"description"];
    
    return postData;
}


@end



// Pin Data Set -----------------------------//
@implementation MomoPinDataSet

+ (NSString *)primaryKey {
    return @"pk";
}

+ (NSArray<NSString *> *)requiredProperties {
    return @[@"pk", @"pin_name", @"pin_label"];     // + pin_map_pk
}


// 핀 생성, Momo 서버로부터 받아온 Dic으로 객체 생성, 반환
+ (MomoPinDataSet *)makePinWithDic:(NSDictionary *)pinDic {

    MomoPinDataSet *pinData = [[MomoPinDataSet alloc] init];
    
    pinData.pk = [[pinDic objectForKey:@"pk"] integerValue];
    pinData.pin_map_pk = [[pinDic objectForKey:@"map"] integerValue];
    pinData.pin_name = [pinDic objectForKey:@"pin_name"];
    pinData.pin_label = [[pinDic objectForKey:@"pin_label"] integerValue];
    pinData.pin_created_date = [pinDic objectForKey:@"created_date"];

    // pin_author
    pinData.pin_author = [MomoAuthorDataSet makeAuthorWithDic:[pinDic objectForKey:@"author"]];
    
    // pin_place
    pinData.pin_place = [MomoPlaceDataSet makePlaceWithDic:[pinDic objectForKey:@"place"]];
    
    
    return pinData;
}


// 핀 생성 및 등록
+ (MomoPinDataSet *)makePinWithName:(NSString *)pinName
                       withPinLabel:(NSInteger)pinLabel
                            withMap:(NSInteger)mapIndex {
    
    MomoPinDataSet *pinData = [[MomoPinDataSet alloc] init];
    
    pinData.pin_name = pinName;
    pinData.pin_label = pinLabel;
    pinData.pin_map_pk = [DataCenter myMapList][mapIndex].pk;
    
    MomoPlaceDataSet *placeData = [[MomoPlaceDataSet alloc] init];
    placeData.place_lat = 37.515692;
    placeData.place_lng = 127.021302;
    
    pinData.pin_place = placeData;
    
    NSLog(@"name : %@, label : %ld, mapIndex : %ld", pinName, pinLabel, mapIndex);
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
        [[DataCenter myMapList][mapIndex].map_pin_list addObject:pinData];
    }];
    
    return pinData;
}

- (UIColor *)labelColor {
    switch (self.pin_label) {
        case 0:
            return [UIColor mm_cafe0ColorColor];
        case 1:
            return [UIColor mm_food1ColorColor];
        case 2:
            return [UIColor mm_shop2ColorColor];
        case 3:
            return [UIColor mm_place3ColorColor];
        default:
            return [UIColor mm_etc4ColorColor];
    }
}


// 핀 라벨 아이콘, 색 선택 메서드
- (UIImage *)labelIcon {
    switch (self.pin_label) {
        case 0:
            return [UIImage imageNamed:@"01S"];
        case 1:
            return [UIImage imageNamed:@"02S"];
        case 2:
            return [UIImage imageNamed:@"03S"];
        case 3:
            return [UIImage imageNamed:@"04S"];
        default:
            return [UIImage imageNamed:@"05S"];
    }
}

@end



// Map Data Set -----------------------------//
@implementation MomoMapDataSet

+ (NSString *)primaryKey {
    return @"pk";
}

+ (NSArray<NSString *> *)requiredProperties {
    return @[@"pk", @"map_name", @"map_is_private"];
}


// 맵 생성, Momo 서버로부터 받아온 Dic으로 객체 생성, 반환
+ (MomoMapDataSet *)makeMapWithDic:(NSDictionary *)mapDic {
    
    MomoMapDataSet *mapData = [[MomoMapDataSet alloc] init];
    
    mapData.pk = [[mapDic objectForKey:@"pk"] integerValue];
    mapData.map_name = [mapDic objectForKey:@"map_name"];
    
    mapData.map_description = [mapDic objectForKey:@"description"];
    mapData.map_created_date = [mapDic objectForKey:@"created_date"];
    mapData.map_is_private = [[mapDic objectForKey:@"is_private"] boolValue];
    
    // map_author
    mapData.map_author = [MomoAuthorDataSet makeAuthorWithDic:[mapDic objectForKey:@"author"]];
    
    return mapData;
}


@end




// User Data Set ----------------------------//
@implementation MomoUserDataSet

+ (NSString *)primaryKey {
    return @"pk";
}

+ (NSArray<NSString *> *)requiredProperties {
    return @[@"pk"];
}



// User profile image
- (void)setUser_profile_image_url:(NSString *)user_profile_image_url {
    NSLog(@"setUser_profile_image_url setter");

    if (user_profile_image_url) {       // nil이 아닐 때
        // url 설정하면서 자동으로 이미지 가져옴
        _user_profile_image_url = user_profile_image_url;
        self.user_profile_image_data = [NSData dataWithContentsOfURL:[NSURL URLWithString:user_profile_image_url]];
    }
}

- (UIImage *)getUserProfileImage {
    return [UIImage imageWithData:self.user_profile_image_data];
}

@end



