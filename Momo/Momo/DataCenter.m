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
    
    
    // UserData 세팅
//    [self fetchMomoUserData];
    

    // 테스트용 데이터, 아이콘들 -----------------------//
    
    self.tabBarIconArr = [[NSMutableArray alloc] initWithArray:[self getTabBarItemIconsArr]];
    
    // 더미 위치 데이터
    self.locationArr = [[NSMutableArray alloc] initWithArray:@[@[
                                                                   @37.517181f, @127.028488f, @"1번 마커", [UIColor brownColor],
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


// Account Token 자동로그인 ------------------------------//
#pragma mark - Auto Login / Token getter

- (NSString *)getUserToken {
    // Token != nil이면 Login 되어있음
    return [DataCenter sharedInstance].momoUserData.user_token;
}

//- (FBSDKAccessToken *)getUserFBToken {
//    // Token != nil이면 Login 되어있음
//    return [DataCenter sharedInstance].momoUserData.user_fb_token;
//}



// User Data 저장, 불러오기, 삭제 --------------------------//
#pragma mark - MOMO User Data 저장, 불러오기, 삭제
// 일단 NSUserDefaults에 저장

// 저장
- (void)saveMomoUserData {
    NSLog(@"saveMomoUserData : %@", self.momoUserData);
    [[NSUserDefaults standardUserDefaults] setObject:self.momoUserData.user_token forKey:@"token"];
//    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@", self.momoUserData.user_fb_token] forKey:@"fb_token"];      // non p-list type error
    
}

// 불러오기
- (void)fetchMomoUserDataWithCompletionBlock:(void (^)(BOOL isSuccess))completionBlock {
    
    NSLog(@"token : %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"token"]);
//    NSLog(@"fb_token : %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"fb_token"]);

    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"token"]) {     // nil이 아닐 때 불러옴
        
        // 페북 계정 & 유저 정보 불러와서 프로퍼티로 Set
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"fb_token"]) {

            [FacebookModule getFacebookProfileInfosWithCompletionBlock:^(MomoUserDataSet *momoUserData) {
                self.momoUserData = momoUserData;
                completionBlock(YES);
            }];
            // fb계정의 경우 추가로 모모 서버랑 연결해서 정보 가져와야 함
            
        } else {
            // 이메일 계정 & 유저 정보 불러와서 프로퍼티로 Set
            [NetworkModule getUserProfileInfosWithToken:[[NSUserDefaults standardUserDefaults] objectForKey:@"token"] withCompletionBlock:^(MomoUserDataSet *momoUserData) {
                self.momoUserData = momoUserData;
                completionBlock(YES);
            }];
        }
    } else {    // 토큰 없을 때
        completionBlock(NO);
    }
}

// 삭제
- (void)removeMomoUserData {
    self.momoUserData = nil;
    NSLog(@"removeUserData %@", self.momoUserData);
    NSLog(@"user_token : %@", self.momoUserData.user_token);

    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"token"];
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"fb_token"];
    NSLog(@"removeMomoUserData : %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"token"]);
}


@end


