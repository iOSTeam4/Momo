//
//  NetworkModule.m
//  Momo
//
//  Created by Jeheon Choi on 2017. 3. 27..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import "NetworkModule.h"

// 일단 이전 Network 실습에 사용한 서버 및 코드 테스트용으로 사용


static NSString *const API_BASE_URL     = @"https://fc-ios.lhy.kr/api";

static NSString *const SIGN_UP_URL      = @"/member/signup/";
static NSString *const LOG_IN_URL       = @"/member/login/";
static NSString *const LOG_OUT_URL      = @"/member/logout/";
static NSString *const USER_DETAIL_URL  = @"/member/profile/";


@implementation NetworkModule



// Facebook account -------------------------------//
#pragma mark - Facebook Auth Account Methods

// FBSDKLoginManager Singleton Instance
+ (FBSDKLoginManager *)sharedFBLoginManeger {
    
    static FBSDKLoginManager *fbLoginManeger;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fbLoginManeger = [[FBSDKLoginManager alloc] init];
        fbLoginManeger.loginBehavior = FBSDKLoginBehaviorSystemAccount;
    });
    
    return fbLoginManeger;
}



// Facebook Login (& Sign Up)
+ (void)FacebookLoginFromVC:(UIViewController *)fromVC
        WithCompletionBlock:(void (^)(BOOL isSuccess, NSString *token))completionBlock {
    
    
    [[self sharedFBLoginManeger] logInWithReadPermissions:@[@"public_profile", @"email", @"user_friends"]
                                       fromViewController:fromVC
                                                  handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                                      if (error == nil) {
                                                          
                                                          NSLog(@"Current Token : %@ | Token String : %@", [FBSDKAccessToken currentAccessToken],[FBSDKAccessToken currentAccessToken].tokenString);
                                                          
                                                          if (!result.isCancelled) {
                                                              [DataCenter setUserTokenWithStr: [FBSDKAccessToken currentAccessToken].tokenString];
                                                          }
                                                          
                                                          completionBlock(!result.isCancelled, result.token.tokenString);    // isCancelled가 NO면 참
                                                          
                                                      } else {
                                                          NSLog(@"network error code %ld", error.code);
                                                          completionBlock(NO, nil);
                                                      }
                                                  }];
}


// Facebook Log out
+ (void)FacebookLogOutWithCompletionBlock:(void (^)(BOOL isSuccess))completionBlock {
    
    if ([FBSDKAccessToken currentAccessToken]) {
        [[self sharedFBLoginManeger] logOut];
        completionBlock(YES);
    }
}





// E-mail account ---------------------------------//
#pragma mark - E-mail Auth Account Methods

// Sign Up
+ (void)signUpRequestWithUsername:(NSString *)username
                    withPassword1:(NSString *)password1
                    withPassword2:(NSString *)password2
                        withEmail:(NSString *)email
              withCompletionBlock:(void (^)(BOOL isSuccess, NSDictionary* result))completionBlock {
    
    // Session
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    // Request
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", API_BASE_URL, SIGN_UP_URL]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    request.HTTPBody = [[NSString stringWithFormat:@"username=%@&password1=%@&password2=%@&email=%@", username, password1, password2, email] dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPMethod = @"POST";
    
    // Task
    NSURLSessionUploadTask *postTask = [session uploadTaskWithRequest:request
                                                             fromData:nil
                                                    completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                        
                                                        NSLog(@"%@", [[NSString alloc] initWithData: data encoding:NSUTF8StringEncoding]);
                                                        
                                                        if (error == nil) {
                                                            NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                                                            NSLog(@"%@",[responseDic objectForKey:@"key"]);
                                                            
                                                            [DataCenter setUserTokenWithStr:[responseDic objectForKey:@"key"]];
                                                            completionBlock([responseDic objectForKey:@"key"]!=nil, responseDic);
                                                            
                                                        } else {
                                                            NSLog(@"network error code %ld", error.code);
                                                            completionBlock(NO, nil);
                                                        }
                                                    }];
    
    [postTask resume];
}


// Login
+ (void)loginRequestWithUsername:(NSString *)username
                    withPassword:(NSString *)password
             withCompletionBlock:(void (^)(BOOL isSuccess, NSDictionary* result))completionBlock {
    
    // Session
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    // Request
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", API_BASE_URL, LOG_IN_URL]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    request.HTTPBody = [[NSString stringWithFormat:@"username=%@&password=%@", username, password] dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPMethod = @"POST";
    
    // Task
    NSURLSessionUploadTask *postTask = [session uploadTaskWithRequest:request
                                                             fromData:nil
                                                    completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                        
                                                        NSLog(@"%@", [[NSString alloc] initWithData: data encoding:NSUTF8StringEncoding]);
                                                        
                                                        if (error == nil) {
                                                            NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                                                            NSLog(@"%@",[responseDic objectForKey:@"key"]);
                                                            
                                                            [DataCenter setUserTokenWithStr:[responseDic objectForKey:@"key"]];
                                                            completionBlock([responseDic objectForKey:@"key"]!=nil, responseDic);
                                                            
                                                        } else {
                                                            NSLog(@"network error code %ld", error.code);
                                                            completionBlock(NO, nil);
                                                        }
                                                    }];
    
    [postTask resume];
    
}



// Log Out
+ (void)logOutRequestWithCompletionBlock:(void (^)(BOOL isSuccess, NSDictionary* result))completionBlock {
    
    // Session
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    // Request
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", API_BASE_URL, LOG_OUT_URL]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    // 헤더 세팅
    [request addValue:[NSString stringWithFormat:@"token %@", [DataCenter getUserToken]] forHTTPHeaderField:@"Authorization"];
    
    request.HTTPBody = [@"" dataUsingEncoding:NSUTF8StringEncoding];        // @"" 왜 넣어야하지?
    request.HTTPMethod = @"POST";
    
    // Task
    NSURLSessionUploadTask *postTask = [session uploadTaskWithRequest:request
                                                             fromData:nil
                                                    completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                        
                                                        NSLog(@"%@", [[NSString alloc] initWithData: data encoding:NSUTF8StringEncoding]);
                                                        
                                                        // NSLog(@"%@", [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil]);
                                                        
                                                        if (error == nil) {
                                                            NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                                                            
                                                            NSLog(@"로그아웃, token : %@", [DataCenter getUserToken]);
                                                            [DataCenter removeUserToken];
                                                            NSLog(@"초기화 완료 -> token : %@", [DataCenter getUserToken]);
                                                            
                                                            completionBlock(YES, responseDic);
                                                            
                                                        } else {
                                                            NSLog(@"network error code %ld", error.code);
                                                            completionBlock(NO, nil);
                                                        }
                                                    }];
    
    [postTask resume];
    
}


@end
