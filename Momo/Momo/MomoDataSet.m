//
//  MomoDataSet.m
//  Momo
//
//  Created by Jeheon Choi on 2017. 4. 10..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import "MomoDataSet.h"


// Place Data Set ---------------------------//
@implementation MomoPlaceDataSet

//+ (NSString *)primaryKey {
//    return @"pk";
//}

@end


// Post Data Set ---------------------------//
@implementation MomoPostDataSet

//+ (NSString *)primaryKey {
//    return @"pk";
//}

- (UIImage *)getPostImage {
    return [UIImage sd_imageWithData:self.post_image_data];
}


@end



// Pin Data Set -----------------------------//
@implementation MomoPinDataSet

//+ (NSString *)primaryKey {
//    return @"pk";
//}

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

//+ (NSString *)primaryKey {
//    return @"pk";
//}

@end




// User Data Set ----------------------------//
@implementation MomoUserDataSet

//+ (NSString *)primaryKey {
//    return @"pk";
//}


- (UIImage *)getUserProfileImage {
    return [UIImage imageWithData:self.user_profile_image_data];
}

@end



