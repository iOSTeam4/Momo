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
        
        if (![_profile_img_url isEqualToString:profile_img_url]) {
            // 기존 img url과 다를 때, 이미지 불러오고 저장
            NSLog(@"author pk : %ld, img load", self.pk);
            
            _profile_img_url = profile_img_url;
            self.profile_img_data = [NSData dataWithContentsOfURL:[NSURL URLWithString:profile_img_url]];
        }

    }
}

- (UIImage *)getAuthorProfileImg {
    return [UIImage imageWithData:self.profile_img_data];
}


// Author 생성, Momo 서버로부터 받아온 Dic으로 객체 생성, 반환
+ (MomoAuthorDataSet *)makeAuthorWithDic:(NSDictionary *)authorDic {
    
    MomoAuthorDataSet *authorData;
    
    if ([MomoAuthorDataSet objectsWhere:[NSString stringWithFormat:@"pk==%ld", [[authorDic objectForKey:@"pk"] integerValue]]].count > 0) {
        authorData = [MomoAuthorDataSet objectsWhere:[NSString stringWithFormat:@"pk==%ld", [[authorDic objectForKey:@"pk"] integerValue]]][0];

    } else {
        authorData = [[MomoAuthorDataSet alloc] init];
        authorData.pk = [[authorDic objectForKey:@"pk"] integerValue];
    }
    
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
    
    MomoPlaceDataSet *placeData;
    
    if ([MomoPlaceDataSet objectsWhere:[NSString stringWithFormat:@"pk==%ld", [[placeDic objectForKey:@"pk"] integerValue]]].count > 0) {
        placeData = [MomoAuthorDataSet objectsWhere:[NSString stringWithFormat:@"pk==%ld", [[placeDic objectForKey:@"pk"] integerValue]]][0];
        
    } else {
        placeData = [[MomoPlaceDataSet alloc] init];
        placeData.pk = [[placeDic objectForKey:@"pk"] integerValue];
    }
    
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
        
        if (![_post_photo_thumbnail_url isEqualToString:post_photo_url]) {
            // 기존 img url과 다를 때, 이미지 불러오고 저장
            NSLog(@"post pk : %ld, img load", self.pk);
            
            _post_photo_url = post_photo_url;
            self.post_photo_data = [NSData dataWithContentsOfURL:[NSURL URLWithString:post_photo_url]];
        }
    }
}

- (void)setPost_photo_thumbnail_url:(NSString *)post_photo_thumbnail_url {
    NSLog(@"setPost_photo_thumbnail_url setter %@", post_photo_thumbnail_url);
    
    if (post_photo_thumbnail_url) {       // nil이 아닐 때
        // url 설정하면서 자동으로 이미지 가져옴
        
        if (![_post_photo_thumbnail_url isEqualToString:post_photo_thumbnail_url]) {
            // 기존 img url과 다를 때, 이미지 불러오고 저장
            NSLog(@"post pk : %ld, img load", self.pk);
            
            _post_photo_thumbnail_url = post_photo_thumbnail_url;
            self.post_photo_thumbnail_data = [NSData dataWithContentsOfURL:[NSURL URLWithString:post_photo_thumbnail_url]];
        }
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
    //realm transaction 속에서 불림

    MomoPostDataSet *postData;
    
    if ([DataCenter findPinDataWithPinPK:[[postDic objectForKey:@"pk"] integerValue]] != nil) {
        postData = [DataCenter findPostDataWithPostPK:[[postDic objectForKey:@"pk"] integerValue]];

    } else {
        postData = [[MomoPostDataSet alloc] init];
        postData.pk = [[postDic objectForKey:@"pk"] integerValue];
    }
    

    postData.post_pin_pk = [[postDic objectForKey:@"pin"] integerValue];
    postData.post_author = [MomoAuthorDataSet makeAuthorWithDic:[postDic objectForKey:@"author"]];
    
    postData.post_photo_url = [[postDic objectForKey:@"photo"] objectForKey:@"full_size"];
//    postData.post_photo_url = [[postDic objectForKey:@"photo"] objectForKey:@"thumbnail"];
    
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
    //realm transaction 속에서 불림

    MomoPinDataSet *pinData;
    
    if ([DataCenter findPinDataWithPinPK:[[pinDic objectForKey:@"pk"] integerValue]] != nil) {
        pinData = [DataCenter findPinDataWithPinPK:[[pinDic objectForKey:@"pk"] integerValue]];
    
    } else {
        pinData = [[MomoPinDataSet alloc] init];
        pinData.pk = [[pinDic objectForKey:@"pk"] integerValue];
        pinData.pin_post_list = (RLMArray<MomoPostDataSet *><MomoPostDataSet> *)[[RLMArray alloc] initWithObjectClassName:@"MomoPostDataSet"];        
    }
    

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
    //realm transaction 속에서 불림

    MomoMapDataSet *mapData;
    
    if ([DataCenter findMapDataWithMapPK:[[mapDic objectForKey:@"pk"] integerValue]] != nil) {
        mapData = [DataCenter findMapDataWithMapPK:[[mapDic objectForKey:@"pk"] integerValue]];
        
    } else {
        mapData = [[MomoMapDataSet alloc] init];
        mapData.pk = [[mapDic objectForKey:@"pk"] integerValue];
        mapData.map_pin_list = (RLMArray<MomoPinDataSet *><MomoPinDataSet> *)[[RLMArray alloc] initWithObjectClassName:@"MomoPinDataSet"];
    }
    
    
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
        
        if (![_user_profile_image_url isEqualToString:user_profile_image_url]) {
            // 기존 img url과 다를 때, 이미지 불러오고 저장
            NSLog(@"user pk : %ld, img load", self.pk);
            
            _user_profile_image_url = user_profile_image_url;
            self.user_profile_image_data = [NSData dataWithContentsOfURL:[NSURL URLWithString:user_profile_image_url]];
        }
    }
}

- (UIImage *)getUserProfileImage {
    return [UIImage imageWithData:self.user_profile_image_data];
}


+ (MomoUserDataSet *)makeUserWithDic:(NSDictionary *)userDic {
    //realm transaction 속에서 불림
    
    MomoUserDataSet *userData;
    
    if ([MomoUserDataSet objectsWhere:[NSString stringWithFormat:@"pk==%ld", [[userDic objectForKey:@"pk"] integerValue]]].count > 0) {
        userData = [MomoUserDataSet objectsWhere:[NSString stringWithFormat:@"pk==%ld", [[userDic objectForKey:@"pk"] integerValue]]][0];
        
    } else {
        userData = [[MomoUserDataSet alloc] init];
        userData.pk = [[userDic objectForKey:@"pk"] integerValue];
    }
    
    
    userData.user_token = [userDic objectForKey:@"auth_token"];
    
    userData.user_username = [userDic objectForKey:@"username"];
    userData.user_id = [userDic objectForKey:@"userid"];

    if (![[NSString stringWithFormat:@"%@", [userDic objectForKey:@"description"]] isEqualToString:@"<null>"]) {     // null값이 참 이상하게 날라옴..
        userData.user_description = [userDic objectForKey:@"description"];
    }
    
    if ([userDic objectForKey:@"email"]) {
        userData.user_email = [userDic objectForKey:@"email"];
    }

    if ([[userDic objectForKey:@"profile_img"] objectForKey:@"thumbnail"]) {
        userData.user_profile_image_url = [[userDic objectForKey:@"profile_img"] objectForKey:@"thumbnail"];
    }
        
    
    return userData;
}



@end



// Log in Data Set --------------------------//
@implementation MomoLoginDataSet

+ (NSArray<NSString *> *)requiredProperties {
    return @[@"pk", @"token"];
}

@end


