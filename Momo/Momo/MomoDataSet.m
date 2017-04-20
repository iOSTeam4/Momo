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

@end


// Post Data Set ---------------------------//
@implementation MomoPostDataSet

//+ (NSArray<NSString *> *)requiredProperties {
//    return @[@"pk"];     // + post_pin_pk
//}

- (UIImage *)getPostImage {
    return [UIImage imageWithData:self.post_image_data];
}


@end



// Pin Data Set -----------------------------//
@implementation MomoPinDataSet

//+ (NSArray<NSString *> *)requiredProperties {
//    return @[@"pk", @"pin_name", @"pin_label"];     // + pin_map_pk
//}

// 핀 생성 및 등록
+ (MomoPinDataSet *)makePinWithName:(NSString *)pinName
                       withPinLabel:(NSInteger)pinLabel
                            withMap:(NSInteger)mapIndex {
    
    MomoPinDataSet *pinData = [[MomoPinDataSet alloc] init];
    
    pinData.pin_name = pinName;
    pinData.pin_label = pinLabel;
    pinData.pin_map = [DataCenter myMapList][mapIndex];
    
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

//+ (NSArray<NSString *> *)requiredProperties {
//    return @[@"pk", @"map_name"];
//}

// 맵 생성 및 등록
+ (MomoMapDataSet *)makeMapWithName:(NSString *)mapName
                 withMapDescription:(NSString *)mapDescription
                        withPrivate:(BOOL)isPrivate {
    
    MomoMapDataSet *mapData = [[MomoMapDataSet alloc] init];
    
    mapData.map_name = mapName;
    mapData.map_description = mapDescription;
    mapData.map_is_private = isPrivate;
    
    NSLog(@"name : %@, content : %@, private : %d", mapName, mapDescription, isPrivate);
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
        [[DataCenter myMapList] addObject:mapData];
    }];
    
    return mapData;
}

@end




// User Data Set ----------------------------//
@implementation MomoUserDataSet

+ (NSArray<NSString *> *)requiredProperties {
    return @[@"pk", @"user_token"];
}

- (UIImage *)getUserProfileImage {
    return [UIImage imageWithData:self.user_profile_image_data];
}

@end



