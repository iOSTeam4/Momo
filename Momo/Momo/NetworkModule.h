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
                    withPassword1:(NSString *)password1
                    withPassword2:(NSString *)password2
                        withEmail:(NSString *)email
              withCompletionBlock:(void (^)(BOOL isSuccess, NSDictionary* result))completionBlock;

// Login
+ (void)loginRequestWithUsername:(NSString *)username
                    withPassword:(NSString *)password
             withCompletionBlock:(void (^)(BOOL isSuccess, NSDictionary* result))completionBlock;


// Common ----------------------------------------//

#pragma mark - Account Common Methods
// Log Out
+ (void)logOutRequestWithCompletionBlock:(void (^)(BOOL isSuccess, NSDictionary* result))completionBlock;


// 서버로부터 유저 정보들 받아오는 메서드
+ (void)getEmailUserProfileInfosWithToken:(NSString *)token withCompletionBlock:(void (^)(MomoUserDataSet *momoUserData))completionBlock;

// 서버로부터 유저 지도리스트 받아오는 메서드
+ (void)getUserMapDataWithCompletionBlock:(void (^)(NSArray<MomoMapDataSet *> *user_map_list))completionBlock;

@end
