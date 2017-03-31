//
//  DataCenter.h
//  Momo
//
//  Created by Jeheon Choi on 2017. 3. 27..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FAKFontAwesome;

@interface DataCenter : NSObject

// 싱글턴 객체 호출 메소드
+ (instancetype)sharedInstance;




// 기본 세팅 관련 ----------------------------------------//


@property (nonatomic) NSMutableArray *tabBarIconArr;    // 테스트용 탭바 아이콘 어레이

@property (nonatomic) NSMutableArray *locationArr;      // 테스트용 위치 데이터 어레이


#pragma mark - Icon 관련

// TabBar Item Icons
- (NSArray *)getTabBarItemIconsArr;

@end




// Account Category : 계정 관련 -------------------------//

@interface DataCenter (Account)

#pragma mark - Token setter, getter, remover

+ (NSString *)getUserToken;                             // Token get
+ (void)setUserTokenWithStr:(NSString *)tokenStr;       // Token set
+ (void)removeUserToken;                                // Token remove

@end
