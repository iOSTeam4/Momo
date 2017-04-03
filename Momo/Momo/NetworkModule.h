//
//  NetworkModule.h
//  Momo
//
//  Created by Jeheon Choi on 2017. 3. 27..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkModule : NSObject



// Facebook account -------------------------------//
#pragma mark - Facebook Auth Account Methods

// Facebook Login (& Sign Up)
+ (void)FacebookLoginFromVC:(UIViewController *)fromVC
        WithCompletionBlock:(void (^)(BOOL isSuccess, NSString *token))completionBlock ;
// Facebook Log Out
+ (void)FacebookLogOutWithCompletionBlock:(void (^)(BOOL isSuccess))completionBlock;



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

// Log Out
+ (void)logOutRequestWithCompletionBlock:(void (^)(BOOL isSuccess, NSDictionary* result))completionBlock;


@end
