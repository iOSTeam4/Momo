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
                                                            
                                                            [self getUserProfileInfosWithToken:[responseDic objectForKey:@"key"] withCompletionBlock:^(MomoUserDataSet *momoUserData) {
                                                                
                                                                [DataCenter sharedInstance].momoUserData = momoUserData;
                                                                
                                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                                    completionBlock([responseDic objectForKey:@"key"]!=nil, responseDic);
                                                                });
                                                            }];
                                                            
                                                        } else {
                                                            NSLog(@"network error : %@", error.description);
                                                            
                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                completionBlock(NO, nil);
                                                            });
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
                                                            
                                                            [self getUserProfileInfosWithToken:[responseDic objectForKey:@"key"] withCompletionBlock:^(MomoUserDataSet *momoUserData) {
                                                                
                                                                [DataCenter sharedInstance].momoUserData = momoUserData;
                                                                
                                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                                    completionBlock([responseDic objectForKey:@"key"]!=nil, responseDic);
                                                                });
                                                            }];
                                                
                                                        } else {
                                                            NSLog(@"network error : %@", error.description);
                                                            
                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                completionBlock(NO, nil);
                                                            });
                                                        }
                                                    }];
    
    [postTask resume];
    
}


#pragma mark - Account Common Methods

// Log Out (Facebook & e-mail 계정)
+ (void)logOutRequestWithCompletionBlock:(void (^)(BOOL isSuccess, NSDictionary* result))completionBlock {
    
    NSLog(@"로그아웃, token : %@", [[DataCenter sharedInstance] getUserToken]);
    [[DataCenter sharedInstance] removeMomoUserData];           // 토큰을 비롯한 유저 데이터 삭제
    NSLog(@"초기화 완료 -> token : %@", [[DataCenter sharedInstance] getUserToken]);
    
    
    if ([FBSDKAccessToken currentAccessToken]) { // Facebook 계정
        NSLog(@"Facebook Log out");
        
        [FacebookModule fbLogOut];
//        [[DataCenter sharedInstance] removeMomoUserData];       // 토큰을 비롯한 유저 데이터 삭제

        completionBlock(YES, nil);
        
    } else {        // e-mail 계정
        NSLog(@"e-mail account Log out");

        // Session
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        
        // Request
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", API_BASE_URL, LOG_OUT_URL]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        
        // 헤더 세팅
        [request addValue:[NSString stringWithFormat:@"token %@", [[DataCenter sharedInstance] getUserToken]] forHTTPHeaderField:@"Authorization"];
        
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
                                                                
//                                                                [[DataCenter sharedInstance] removeMomoUserData];           // 토큰을 비롯한 유저 데이터 삭제
                                                                
                                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                                    completionBlock(YES, responseDic);
                                                                });
                                                                
                                                            } else {
                                                                NSLog(@"network error : %@", error.description);
                                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                                    completionBlock(NO, nil);
                                                                });
                                                            }
                                                        }];
        
        [postTask resume];
    }
}


// 서버로부터 유저 정보들 받아오는 메서드
+ (void)getUserProfileInfosWithToken:(NSString *)token withCompletionBlock:(void (^)(MomoUserDataSet *momoUserData))completionBlock {
    NSLog(@"getUserProfileInfosWithToken, token : %@", token);
    MomoUserDataSet *momoUserData = [[MomoUserDataSet alloc] init];
    momoUserData.user_token = token;
    
    // 서버로부터 유저 정보 받아와 세팅할 부분
    
    completionBlock(momoUserData);
}


@end
