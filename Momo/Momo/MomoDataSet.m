//
//  MomoDataSet.m
//  Momo
//
//  Created by Jeheon Choi on 2017. 4. 10..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import "MomoDataSet.h"

// Author Data Set ---------------------------//
@interface MomoAuthorDataSet ()

@property (nonatomic) BOOL getProfileImgDataWithURL;     // Photo Data를 서버의 URL로부터 가져오는 것을 결정하는 프로퍼티

@end

@implementation MomoAuthorDataSet

+ (NSString *)primaryKey {
    return @"pk";
}


// Img 세팅 관련
- (void)setProfile_img_url:(NSString *)profile_img_url {
    NSLog(@"setProfile_img_url setter %@", profile_img_url);
    
    if (profile_img_url) {       // nil이 아닐 때
        // url 설정하면서 자동으로 이미지 가져옴
        
        if (![_profile_img_url isEqualToString:profile_img_url]) {
            // 기존 img url과 다를 때, 이미지 불러오고 저장
            
            _profile_img_url = profile_img_url;
            
            if (self.getProfileImgDataWithURL) {
                self.profile_img_data = [NSData dataWithContentsOfURL:[NSURL URLWithString:profile_img_url]];
            }
        }
    }
}

- (UIImage *)getAuthorProfileImg {
    return [UIImage imageWithData:self.profile_img_data];
}



// Momo 서버로부터 받아온 AuthorDic으로 Author 객체 세팅(생성 or 업데이트) & 반환
+ (MomoAuthorDataSet *)parseAuthorDic:(NSDictionary *)authorDic withProfileImgData:(NSData *)imgData {
    //realm transaction 속에서 불림
    
    MomoAuthorDataSet *authorData;
    
    if ([MomoAuthorDataSet objectsWhere:[NSString stringWithFormat:@"pk==%ld", [[authorDic objectForKey:@"pk"] integerValue]]].count > 0) {
        authorData = [MomoAuthorDataSet objectsWhere:[NSString stringWithFormat:@"pk==%ld", [[authorDic objectForKey:@"pk"] integerValue]]][0];
        
    } else {
        authorData = [[MomoAuthorDataSet alloc] init];
        authorData.pk = [[authorDic objectForKey:@"pk"] integerValue];
    }
    
    
    // 프사는 업로드(수정)할 때, 사용한 imgData 그대로 사용 (서버 URL로 부터 imgData 다시 받아오지 않음)
    if (imgData != nil) {
        authorData.getProfileImgDataWithURL = NO;
        authorData.profile_img_data = imgData;
    } else {
        authorData.getProfileImgDataWithURL = YES;
    }
    
    authorData.username = [authorDic objectForKey:@"username"];
    authorData.profile_img_url = [[authorDic objectForKey:@"profile_img"] objectForKey:@"thumbnail"];
    
    return authorData;
}


@end


// Place Data Set ---------------------------//
@implementation MomoPlaceDataSet

+ (NSString *)primaryKey {
    return @"pk";
}


// Momo 서버로부터 받아온 PlaceDic으로 Place 객체 세팅(생성 or 업데이트) & 반환
+ (MomoPlaceDataSet *)parsePlaceDic:(NSDictionary *)placeDic {
    //realm transaction 속에서 불림
    
    MomoPlaceDataSet *placeData;
    
    if ([MomoPlaceDataSet objectsWhere:[NSString stringWithFormat:@"pk==%ld", [[placeDic objectForKey:@"pk"] integerValue]]].count > 0) {
        placeData = [MomoPlaceDataSet objectsWhere:[NSString stringWithFormat:@"pk==%ld", [[placeDic objectForKey:@"pk"] integerValue]]][0];
        
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
@interface MomoPostDataSet ()

@property (nonatomic) BOOL getPhotoDataWithURL;     // Photo Data를 서버의 URL로부터 가져오는 것을 결정하는 프로퍼티

@end



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
        
        if (![_post_photo_url isEqualToString:post_photo_url]) {
            // 기존 img url과 다를 때, 이미지 불러오고 저장
            
            _post_photo_url = post_photo_url;
            
            if (self.getPhotoDataWithURL) {
                NSLog(@"post pk : %ld, img load", self.pk);
                self.post_photo_data = [NSData dataWithContentsOfURL:[NSURL URLWithString:post_photo_url]];
            }
        }
    }
}

- (void)setPost_photo_thumbnail_url:(NSString *)post_photo_thumbnail_url {
    NSLog(@"setPost_photo_thumbnail_url setter %@", post_photo_thumbnail_url);
    
    if (post_photo_thumbnail_url) {       // nil이 아닐 때
        // url 설정하면서 자동으로 이미지 가져옴
        
        if (![_post_photo_thumbnail_url isEqualToString:post_photo_thumbnail_url]) {
            // 기존 img url과 다를 때, 이미지 불러오고 저장
            
            _post_photo_thumbnail_url = post_photo_thumbnail_url;
            
            if (self.getPhotoDataWithURL) {
                NSLog(@"post pk : %ld, thumbnail_img load", self.pk);
                self.post_photo_thumbnail_data = [NSData dataWithContentsOfURL:[NSURL URLWithString:post_photo_thumbnail_url]];
            }
        }
    }
}

- (UIImage *)getPostPhoto {
    return [UIImage imageWithData:self.post_photo_data];
}

- (UIImage *)getPostPhotoThumbnail {
    return [UIImage imageWithData:self.post_photo_thumbnail_data];
}




// Momo 서버로부터 받아온 PostDic으로 Post 객체 세팅(생성 or 업데이트) & 반환
+ (MomoPostDataSet *)parsePostDic:(NSDictionary *)postDic withPhotoData:(NSData *)photoData {
    //realm transaction 속에서 불림
    
    MomoPostDataSet *postData;
    
    if ([DataCenter findPostDataWithPostPK:[[postDic objectForKey:@"pk"] integerValue]] != nil) {
        postData = [DataCenter findPostDataWithPostPK:[[postDic objectForKey:@"pk"] integerValue]];

    } else {
        postData = [[MomoPostDataSet alloc] init];
        postData.pk = [[postDic objectForKey:@"pk"] integerValue];
    }
    
    // 사진은 업로드(생성, 수정)할 때, 사용한 photoData 그대로 사용 (서버 URL로 부터 photoData 다시 받아오지 않음)
    if (photoData != nil) {
        postData.getPhotoDataWithURL = NO;
        postData.post_photo_data = photoData;
    } else {
        postData.getPhotoDataWithURL = YES;
    }

    
    postData.post_pin_pk = [[postDic objectForKey:@"pin"] integerValue];
    postData.post_author = [MomoAuthorDataSet parseAuthorDic:[postDic objectForKey:@"author"] withProfileImgData:nil];
    
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


// Momo 서버로부터 받아온 PinDic으로 Pin 객체 세팅(생성 or 업데이트) & 반환
+ (MomoPinDataSet *)parsePinDic:(NSDictionary *)pinDic {
    //realm transaction 속에서 불림
    
    MomoPinDataSet *pinData;
    
    if ([DataCenter findPinDataWithPinPK:[[pinDic objectForKey:@"pk"] integerValue]] != nil) {
        pinData = [DataCenter findPinDataWithPinPK:[[pinDic objectForKey:@"pk"] integerValue]];
    
    } else {
        pinData = [[MomoPinDataSet alloc] init];
        pinData.pk = [[pinDic objectForKey:@"pk"] integerValue];
    }
    

    pinData.pin_map_pk = [[pinDic objectForKey:@"map"] integerValue];
    pinData.pin_name = [pinDic objectForKey:@"pin_name"];
    pinData.pin_label = [[pinDic objectForKey:@"pin_label"] integerValue];
    pinData.pin_created_date = [pinDic objectForKey:@"created_date"];

    // pin_author
    pinData.pin_author = [MomoAuthorDataSet parseAuthorDic:[pinDic objectForKey:@"author"] withProfileImgData:nil];
    
    // pin_place
    pinData.pin_place = [MomoPlaceDataSet parsePlaceDic:[pinDic objectForKey:@"place"]];

    
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


// Momo 서버로부터 받아온 MapDic으로 Map 객체 세팅(생성 or 업데이트) & 반환
+ (MomoMapDataSet *)parseMapDic:(NSDictionary *)mapDic {
    //realm transaction 속에서 불림
    
    MomoMapDataSet *mapData;
    
    if ([DataCenter findMapDataWithMapPK:[[mapDic objectForKey:@"pk"] integerValue]] != nil) {
        mapData = [DataCenter findMapDataWithMapPK:[[mapDic objectForKey:@"pk"] integerValue]];
        
    } else {
        mapData = [[MomoMapDataSet alloc] init];
        mapData.pk = [[mapDic objectForKey:@"pk"] integerValue];
    }
    
    mapData.map_name = [mapDic objectForKey:@"map_name"];
    
    mapData.map_description = [mapDic objectForKey:@"description"];
    mapData.map_created_date = [mapDic objectForKey:@"created_date"];
    mapData.map_is_private = [[mapDic objectForKey:@"is_private"] boolValue];
    
    // map_author
    mapData.map_author = [MomoAuthorDataSet parseAuthorDic:[mapDic objectForKey:@"author"] withProfileImgData:nil];
    
    
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



// Momo 서버로부터 받아온 UserDic으로 User 객체 세팅(생성 or 업데이트) & 반환      (+ with imgData)
+ (MomoUserDataSet *)parseUserDic:(NSDictionary *)userDic withProfileImgData:(NSData *)imgData {
    //realm transaction 속에서 불림
    
    MomoUserDataSet *userData;
    
    if ([MomoUserDataSet objectsWhere:[NSString stringWithFormat:@"pk==%ld", [[userDic objectForKey:@"pk"] integerValue]]].count > 0) {
        userData = [MomoUserDataSet objectsWhere:[NSString stringWithFormat:@"pk==%ld", [[userDic objectForKey:@"pk"] integerValue]]][0];
        
    } else {
        userData = [[MomoUserDataSet alloc] init];
        userData.pk = [[userDic objectForKey:@"pk"] integerValue];
    }
    
    userData.user_token = [userDic objectForKey:@"auth_token"];
    
    // Author에 Username & Profile Img 세팅 (User와 Author는 같음 (pk, username, img))
    userData.user_author = [MomoAuthorDataSet parseAuthorDic:userDic withProfileImgData:imgData];

    
    userData.user_id = [userDic objectForKey:@"userid"];

    if (![[NSString stringWithFormat:@"%@", [userDic objectForKey:@"description"]] isEqualToString:@"<null>"]) {     // null값이 참 이상하게 날라옴..
        userData.user_description = [userDic objectForKey:@"description"];
    }
    
    if ([userDic objectForKey:@"email"]) {
        userData.user_email = [userDic objectForKey:@"email"];
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


