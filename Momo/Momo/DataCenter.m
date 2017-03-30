//
//  DataCenter.m
//  Momo
//
//  Created by Jeheon Choi on 2017. 3. 27..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import "DataCenter.h"


// Class Extensions -----------------------------------//

@interface DataCenter ()


@end




// Class implementation -------------------------------//

@implementation DataCenter

#pragma mark - DataCenter Singleton Instance

// 싱글턴 객체 호출 메소드
+ (instancetype)sharedInstance {
    
    static DataCenter *data;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        data = [[self alloc] init];
    });
    
    
    return data;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        // 초기화
        [self initialDataCenterSetting];
    }
    return self;
}





// 기본 세팅 관련 ----------------------------------------//

- (void)initialDataCenterSetting {

    // 테스트용 데이터, 아이콘들 -----------------------//
    
    self.tabBarIconArr = [[NSMutableArray alloc] initWithArray:[self getTabBarItemIconsArr]];
    
    // 더미 위치 데이터
    self.locationArr = [[NSMutableArray alloc] initWithArray:@[@[
                                                                   @37.503639f, @127.044907f, @"1번 마커", [UIColor brownColor],
                                                                   [self getUIImageIconWithFAKFontAwesomIcon:[FAKFontAwesome coffeeIconWithSize:PIN_MARKER_ICON_IMAGE_SIZE] withSize:PIN_MARKER_ICON_IMAGE_SIZE withColor:[UIColor whiteColor]]
                                                                   ],
                                                               @[
                                                                   @37.565738f, @126.976761f, @"2번 마커 2번 마커", [UIColor orangeColor],
                                                                   [self getUIImageIconWithFAKFontAwesomIcon:[FAKFontAwesome cutleryIconWithSize:PIN_MARKER_ICON_IMAGE_SIZE] withSize:PIN_MARKER_ICON_IMAGE_SIZE withColor:[UIColor whiteColor]]
                                                                   ],
                                                               @[
                                                                   @37.545426f, @126.855904f, @"3번 마커 하하하하하하하하ㅎ하ㅎㅎ", [UIColor redColor],
                                                                   [self getUIImageIconWithFAKFontAwesomIcon:[FAKFontAwesome appleIconWithSize:PIN_MARKER_ICON_IMAGE_SIZE] withSize:PIN_MARKER_ICON_IMAGE_SIZE withColor:[UIColor whiteColor]]
                                                                   ],
                                                               @[
                                                                   @37.321065f, @127.040955f, @"4번 마커 asdavskhbjsh", [UIColor purpleColor],
                                                                   [self getUIImageIconWithFAKFontAwesomIcon:[FAKFontAwesome universityIconWithSize:PIN_MARKER_ICON_IMAGE_SIZE] withSize:PIN_MARKER_ICON_IMAGE_SIZE withColor:[UIColor whiteColor]]
                                                                   ]]];
    
}


#pragma mark - Icon 관련

// TabBar Icon

- (NSArray *)getTabBarItemIconsArr {
    
    NSMutableArray *iconImagearr = [[NSMutableArray alloc] init];
    
    NSArray *iconArr = @[[FAKFontAwesome homeIconWithSize:TABBAR_ICON_IMAGE_SIZE],
                         [FAKFontAwesome mapIconWithSize:TABBAR_ICON_IMAGE_SIZE]];
    
    for (FAKFontAwesome *icon in iconArr) {
        [iconImagearr addObject:[self getUIImageIconWithFAKFontAwesomIcon:icon withSize:TABBAR_ICON_IMAGE_SIZE withColor:[UIColor blackColor]]];
    }
    
    return iconImagearr;
}


// Icon Image Setting

- (UIImage *)getUIImageIconWithFAKFontAwesomIcon:(FAKFontAwesome *)icon withSize:(CGFloat)size withColor:(UIColor *)color{
    
    [icon addAttribute:NSForegroundColorAttributeName value:color];
    UIImage *img = [icon imageWithSize:CGSizeMake(size, size)];
    
    return img;
}




@end


// Account Category : 계정 관련 -------------------------//

@implementation DataCenter (Account)

#pragma mark - Token setter, getter, remover

+ (void)setUserTokenWithStr:(NSString *)tokenStr {
    NSLog(@"Set Token : %@", tokenStr);
    [[NSUserDefaults standardUserDefaults] setObject:tokenStr forKey:@"UserToken"];
}

+ (NSString *)getUserToken {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"UserToken"];
}

+ (void)removeUserToken {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserToken"];
}

@end


