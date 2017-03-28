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
        
        // 더미 위치 데이터
        self.locationArr = [[NSMutableArray alloc] initWithArray:@[@[@37.503639f, @127.044907f],
                                                                   @[@37.565738f, @126.976761f],
                                                                   @[@37.545426f, @126.855904f],
                                                                   @[@37.321065f, @127.040955f]]];
    }
    return self;
}

@end




// Account Category : 계정 관련 -------------------------//

@implementation DataCenter (Account)

#pragma mark - Token setter, getter, remover

+ (void)setUserTokenWithStr:(NSString *)tokenStr {
    [[NSUserDefaults standardUserDefaults] setObject:tokenStr forKey:@"UserToken"];
}

+ (NSString *)getUserToken {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"UserToken"];
}

+ (void)removeUserToken {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserToken"];
}

@end


