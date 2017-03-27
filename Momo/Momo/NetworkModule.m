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
