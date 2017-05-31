//
//  FacebookModule.m
//  Momo
//
//  Created by Jeheon Choi on 2017. 4. 11..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import "FacebookModule.h"

static NSString *const API_BASE_URL         = @"https://momo.kizmo04.com";
static NSString *const FACEBOOK_LOGIN_URL   = @"/api/member/fb/";


@implementation FacebookModule

// Facebook account -------------------------------//

#pragma mark - FacebookModule Singleton Manager
+ (instancetype)fbNetworkManager {
    
    static FacebookModule *fbNetworkManager;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fbNetworkManager = [[FacebookModule alloc] init];
    });
    
    return fbNetworkManager;
}


#pragma mark - Facebook Server API Methods
- (void)fbLogOut {
    [[[FBSDKLoginManager alloc] init] logOut];
}



// Facebook Login (& Sign Up)
- (void)fbLoginFromVC:(UIViewController *)fromVC
  withCompletionBlock:(void (^)(BOOL isSuccess, NSString *result))completionBlock {
    
    [[[FBSDKLoginManager alloc] init]
     logInWithReadPermissions:@[@"public_profile", @"email", @"user_friends"]
     fromViewController:fromVC
     handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
         
         [UtilityModule showIndicator];
         
         // isMainThread
         
         if (error) {
             NSLog(@"network error : %@", error.description);
             
             completionBlock(NO, nil);
             
         } else if (result.isCancelled) {
             NSLog(@"isCancelled");
             
             completionBlock(NO, nil);
             
         } else {
             NSLog(@"Facebook Login Success");
             NSLog(@"fb token : %@", [FBSDKAccessToken currentAccessToken].tokenString);
             
             
             // fb_token 정보 가지고 Momo 서버 Facebook계정 로그인
             [self fbLoginRequestWithFBToken:[FBSDKAccessToken currentAccessToken].tokenString
                         withCompletionBlock:^(BOOL isSuccess, BOOL newMember, NSString *result) {
                 
                             if (isSuccess) {
                                 // 페북 로그인 성공
                                 
                                 if (newMember) {
                                     // 신규 회원
                                     // Facebook id, name, profileImage, email 얻어오기
                                     [self getFacebookProfileInfosWithCompletionBlock:^(BOOL isSuccess) {
                                         
                                         // 페북 서버에서 받아온 추가 정보를 모모 서버에 보냄
                                         [[NetworkModule momoNetworkManager]
                                          patchMemberProfileUpdateWithUsername:[DataCenter sharedInstance].momoUserData.user_author.username
                                          withProfileImgData:[DataCenter sharedInstance].momoUserData.user_author.profile_img_data
                                          withDescription:@"팔로워들에게 자기소개를 해보세요 :0"
                                          withCompletionBlock:^(BOOL isSuccess, NSString *result) {
                                              
                                              // 정보를 잘 가져왔든, 말든 로그인 성공
                                              completionBlock(YES, result);
                                          }];
                                         
                                         
                                     }];
                                 } else {
                                     // 기존 회원
                                     completionBlock(YES, result);
                                 }
                                 
                             } else {
                                 // 페북 로그인 실패
                                 completionBlock(NO, result);
                             }
                             
                         }];
             
         }
     }];
    
}



// Facebook 서버로부터 유저 프로필 정보들 받아와 세팅하는 메서드
// 신규 회원일 경우만 받아옴
- (void)getFacebookProfileInfosWithCompletionBlock:(void (^)(BOOL isSuccess))completionBlock {
    
    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields":@"id, name, picture.type(large), email"}] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        
        // isMainThread
        NSLog(@"FBSDKGraphRequest : %@", result);
        
        if (!error) {
            
            [DataCenter sharedInstance].momoUserData.user_author.pk = [DataCenter sharedInstance].momoLoginData.pk;     // user_author pk 값 반드시 세팅해야 함
    
            // 이름
            if ([result objectForKey:@"name"]) {
                [DataCenter sharedInstance].momoUserData.user_author.username = [result objectForKey:@"name"];
                NSLog(@"momoUserData.user_username : %@", [result objectForKey:@"name"]);
            }
            
            // 프로필 사진
            if ([result objectForKey:@"picture"]) {
                [DataCenter sharedInstance].momoUserData.user_author.profile_img_url = result[@"picture"][@"data"][@"url"];
                [DataCenter sharedInstance].momoUserData.user_author.profile_img_data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[DataCenter sharedInstance].momoUserData.user_author.profile_img_url]];
                NSLog(@"url : %@", result[@"picture"][@"data"][@"url"]);
            }
            
            // 이메일
            if ([result objectForKey:@"email"]) {
                [DataCenter sharedInstance].momoUserData.user_email = [result objectForKey:@"email"];
                NSLog(@"momoUserData.user_email : %@", [DataCenter sharedInstance].momoUserData.user_email);
            }
            
            completionBlock(YES);
            
        } else {
            NSLog(@"network error : %@", error.description);
            completionBlock(NO);
        }
    }];
}


#pragma mark - Facebook Account Momo server API Methods

// Momo 서버 Facebook계정 로그인
- (void)fbLoginRequestWithFBToken:(NSString *)fbToken
              withCompletionBlock:(void (^)(BOOL isSuccess, BOOL newMember, NSString *result))completionBlock {
    
    // Session
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    // Request
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", API_BASE_URL, FACEBOOK_LOGIN_URL]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];

    // 헤더 세팅
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    // 바디 세팅
    NSData *paramData = [[NSString stringWithFormat:@"{\"access_token\":\"%@\"}", fbToken] dataUsingEncoding:NSUTF8StringEncoding];

    request.HTTPBody = paramData;
    request.HTTPMethod = @"POST";
    
    // Task
    NSURLSessionUploadTask *postTask = [session uploadTaskWithRequest:request
                                                             fromData:nil
                                                    completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                        
                                                        NSLog(@"Status Code : %ld", ((NSHTTPURLResponse *)response).statusCode);
                                                        NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                                                        
                                                        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                                                        NSLog(@"responseDic token : %@", [responseDic objectForKey:@"token"]);
                                                        
                                                        // 메인스레드로 돌려서 보냄
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            
                                                            if (!error) {
                                                                if (((NSHTTPURLResponse *)response).statusCode == 200) {
                                                                    // Code: 200 Success
                                                                    
                                                                    NSInteger pk = [[responseDic objectForKey:@"pk"] integerValue];
                                                                    NSString *token = [responseDic objectForKey:@"auth_token"];
                                                                    BOOL newMember = [[responseDic objectForKey:@"is_created"] boolValue];
                                                                    
                                                                    NSLog(@"PK : %ld, Token : %@", pk, token);
                                                            
                                                                    [DataCenter setLoginDataWithPK:pk withToken:token];     // Set User loginData
                                                                    
                                                                    completionBlock(YES, newMember, @"fb 로그인 성공");
                                                                    
                                                                } else if (((NSHTTPURLResponse *)response).statusCode == 401) {
                                                                    // Code: 401 Unauthorized
                                                                    
                                                                    NSLog(@"%@", [responseDic objectForKey:@"detail"]);
                                                                    completionBlock(NO, NO, [responseDic objectForKey:@"detail"]);
                                                                    
                                                                } else {
                                                                    // Code: 400 BAD REQUEST
                                                                    
                                                                    // error
                                                                    NSLog(@"Code: 400 BAD REQUEST");
                                                                    completionBlock(NO, NO, @"Code: 400 BAD REQUEST");
                                                                    
                                                                }
                                                            } else {
                                                                // Network error
                                                                NSLog(@"Network error! Code : %ld - %@", error.code, error.description);
                                                                completionBlock(NO, NO, @"Network error");
                                                            }
                                                            
                                                        });
                                                        
                                                    }];
    [postTask resume];
    
    // AFNetwork Ver.
//    NSString *fbLoginURL = [NSString stringWithFormat:@"%@%@", API_BASE_URL, FACEBOOK_LOGIN_URL];
//    NSDictionary *parameter = @{@"access_token": fbToken};
//    
//    NSLog(@"param : %@", parameter);
//    
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    manager.requestSerializer = [AFJSONRequestSerializer serializer];
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
//    
//    [manager POST:fbLoginURL
//       parameters:parameter
//         progress:nil
//          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//
//              NSLog(@"Code: 200 Success: %@", responseObject);
//
//              NSNumber *pk = [(NSDictionary *)responseObject objectForKey:@"pk"];
//              NSString *token = [(NSDictionary *)responseObject objectForKey:@"token"];
////              BOOL newMember = [[(NSDictionary *)responseObject objectForKey:@"newMember"] boolValue];
//              BOOL newMember = YES;    // 새롭게 가입한 회원
//              
//              NSLog(@"PK : %@, Token : %@", pk, token);
//              
//              // 유저 데이터 세팅
//              [DataCenter sharedInstance].momoUserData.pk = [pk integerValue];
//              [DataCenter sharedInstance].momoUserData.user_token = token;
//              [DataCenter sharedInstance].momoUserData.user_fb_token = fbToken;
//
//              completionBlock(YES, newMember, @"fb 로그인 성공");
//              
//          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//              NSLog(@"Facebook Login Error Code : %ld - %@", error.code, error.description);
//              
//              completionBlock(NO, NO, @"Facebook Login Fail");
//          }];
}


@end
