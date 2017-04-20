//
//  NetworkModule.h
//  Momo
//
//  Created by Jeheon Choi on 2017. 3. 27..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkModule : NSObject

/////////////////////////////////////////////////////
// Account 관련 ------------------------------------//
/////////////////////////////////////////////////////


// E-mail account ---------------------------------//
#pragma mark - E-mail Auth Account Methods

// Sign Up
+ (void)signUpRequestWithUsername:(NSString *)username
                     withPassword:(NSString *)password
                        withEmail:(NSString *)email
              withCompletionBlock:(void (^)(BOOL isSuccess, NSString* result))completionBlock;

// Login
+ (void)loginRequestWithUsername:(NSString *)username
                    withPassword:(NSString *)password
             withCompletionBlock:(void (^)(BOOL isSuccess, NSString* result))completionBlock;


// Common ----------------------------------------//

#pragma mark - Account Common Methods
// Log Out
+ (void)logOutRequestWithCompletionBlock:(void (^)(BOOL isSuccess, NSString* result))completionBlock;
// Get member profile
+ (void)getMemberProfileRequestWithCompletionBlock:(void (^)(BOOL isSuccess, NSString* result))completionBlock;

// 서버로부터 유저 지도정보 패치하는 메서드
+ (void)fetchUserMapData;

@end
