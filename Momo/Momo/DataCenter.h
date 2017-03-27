//
//  DataCenter.h
//  Momo
//
//  Created by Jeheon Choi on 2017. 3. 27..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataCenter : NSObject

// 싱글턴 객체 호출 메소드
+ (instancetype)sharedInstance;

@end




// Account Category : 계정 관련 -------------------------//

@interface DataCenter (Account)

#pragma mark - Token setter, getter, remover

+ (NSString *)getUserToken;                             // Token get
+ (void)setUserTokenWithStr:(NSString *)tokenStr;       // Token set
+ (void)removeUserToken;                                // Token remove

@end
