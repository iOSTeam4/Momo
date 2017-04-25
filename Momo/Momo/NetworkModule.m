//
//  NetworkModule.m
//  Momo
//
//  Created by Jeheon Choi on 2017. 3. 27..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import "NetworkModule.h"


static NSString *const API_BASE_URL         = @"https://momo.kizmo04.com";

static NSString *const SIGN_UP_URL          = @"/api/member/signup-b/"; // @"/api/member/signup/";
static NSString *const LOG_IN_URL           = @"/api/member/login/";
static NSString *const LOG_OUT_URL          = @"/api/member/logout/";
static NSString *const MEMBER_PROFILE_URL   = @"/api/member/";    // + /{user_id}/      user_id -> pk


static NSString *const MAP_URL              = @"/api/map/";
static NSString *const PIN_URL              = @"/api/pin/";
static NSString *const POST_URL             = @"/api/post/";




@implementation NetworkModule


//********************************************************//
//                       Member API                       //
//********************************************************//


// E-mail account ---------------------------------//
#pragma mark - E-mail Auth Account Methods

// Sign Up
+ (void)signUpRequestWithUsername:(NSString *)username
                     withPassword:(NSString *)password
                        withEmail:(NSString *)email
              withCompletionBlock:(void (^)(BOOL isSuccess, NSString* result))completionBlock {
    
    // Session
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    // Request
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", API_BASE_URL, SIGN_UP_URL]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    request.HTTPBody = [[NSString stringWithFormat:@"userid=%@&password=%@&email=%@", username, password, email] dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPMethod = @"POST";
    
    // Task
    NSURLSessionUploadTask *postTask = [session uploadTaskWithRequest:request
                                                             fromData:nil
                                                    completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

                                                        NSLog(@"Status Code : %ld", ((NSHTTPURLResponse *)response).statusCode);
                                                        NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                                                        
                                                        
                                                        // 메인스레드로 돌려서 보냄
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            
                                                            if (!error) {
                                                                if (((NSHTTPURLResponse *)response).statusCode == 201) {
                                                                    // Code: 201 CREATED
                                                                    
                                                                    // 이메일 인증해야 아이디 사용가능
                                                                    completionBlock(YES, @"이메일 인증을 완료해주세요");
                                                                    
                                                                    
                                                                } else {
                                                                    // Code: 400 BAD REQUEST
//                                                                    NSDictionary *responseDic = [[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil] objectForKey:@"detail"];
//                                                                    
//                                                                    if ([responseDic objectForKey:@"username"]) {
                                                                        // momo user의 username은/는 이미 존재합니다.
//                                                                        NSLog(@"%@", [responseDic objectForKey:@"username"][0]);
                                                                        completionBlock(NO, @"momo user의 userid은/는 이미 존재합니다.");
                                                                    // 서버에서 'userid': ['momo user의 userid은/는 이미 존재합니다.'] 갑자기 이렇게 보냄..
                                                                        
//                                                                    } else {
//                                                                        // 유효한 이메일 주소를 입력하십시오.
//                                                                        NSLog(@"%@", [responseDic objectForKey:@"email"][0]);
//                                                                        completionBlock(NO, [responseDic objectForKey:@"email"][0]);
//                                                                    }
                                                                    
                                                                }
                                                            } else {
                                                                // Network error
                                                                NSLog(@"Network error! Code : %ld - %@", error.code, error.description);
                                                                completionBlock(NO, @"Network error");
                                                            }
                                                        });
                                                        
                                                    }];
    
    [postTask resume];
}


// Login
+ (void)loginRequestWithUsername:(NSString *)username
                    withPassword:(NSString *)password
             withCompletionBlock:(void (^)(BOOL isSuccess, NSString* result))completionBlock {
    
    // Session
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    // Request
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", API_BASE_URL, LOG_IN_URL]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//    [request setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    
    
//    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
//    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    request.HTTPBody = [[NSString stringWithFormat:@"username=%@&password=%@", username, password] dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPMethod = @"POST";
    
    // Task
    NSURLSessionUploadTask *postTask = [session uploadTaskWithRequest:request
                                                             fromData:nil
                                                    completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                        
                                                        NSLog(@"Status Code : %ld", ((NSHTTPURLResponse *)response).statusCode);
                                                        NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                                                        
                                                        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                                                        
                                                        
                                                        // 메인스레드로 돌려서 보냄
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                        
                                                            if (!error) {
                                                                if (((NSHTTPURLResponse *)response).statusCode == 200) {
                                                                    // Code: 200 Success
                                                                    
                                                                    NSNumber *pk = [responseDic objectForKey:@"user_pk"];
                                                                    NSString *token = [responseDic objectForKey:@"token"];
                                                                    
                                                                    NSLog(@"PK : %@, Token : %@", pk, token);
                                                                    
                                                                    [DataCenter sharedInstance].momoUserData.pk = [pk integerValue];
                                                                    [DataCenter sharedInstance].momoUserData.user_token = token;
                                                                    
                                                                    completionBlock(YES, @"로그인 성공");
                                                                    
                                                                } else {
                                                                    // Code: 400 BAD REQUEST
                                                                    
                                                                    // error
                                                                    NSLog(@"아이디 또는 비밀번호를 다시 확인하세요.");
                                                                    completionBlock(NO, @"아이디 또는 비밀번호를 다시 확인하세요.");
                                                                    
                                                                }
                                                            } else {
                                                                // Network error
                                                                NSLog(@"Network error! Code : %ld - %@", error.code, error.description);
                                                                completionBlock(NO, @"Network error");
                                                            }
                                                        
                                                        });
                                                        
                                                    }];
    [postTask resume];
}


#pragma mark - Account Common Methods

// Log Out (Facebook & e-mail 계정)
+ (void)logOutRequestWithCompletionBlock:(void (^)(BOOL isSuccess, NSString* result))completionBlock {

    // Facebook 계정 처리 (fb Server)
    if ([FBSDKAccessToken currentAccessToken]) {
        NSLog(@"Facebook Log out");
        [FacebookModule fbLogOut];
    }

    // e-mail & 페북 계정 공통 (Momo Server)

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
                                                        
                                                        NSLog(@"Status Code : %ld", ((NSHTTPURLResponse *)response).statusCode);
                                                        NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                                                        
                                                        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                                                        
                                                        // 메인스레드로 돌려서 보냄
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            
                                                            if (!error) {
                                                                if (((NSHTTPURLResponse *)response).statusCode == 200) {
                                                                    // Code: 200 Success
                                                                    
                                                                    [DataCenter removeMomoUserData];           // 토큰을 비롯한 유저 데이터 삭제
                                                                    
                                                                    // 정상적으로 로그아웃 되었습니다
                                                                    completionBlock(YES, @"정상적으로 로그아웃 되었습니다");
                                                                    
                                                                } else {
                                                                    // Code: 401 Unauthorized
                                                                    
                                                                    // 토큰이 유효하지 않습니다.
                                                                    NSLog(@"%@", [responseDic objectForKey:@"detail"]);
                                                                    completionBlock(NO, [responseDic objectForKey:@"detail"]);
                                                                    
                                                                }
                                                            } else {
                                                                // Network error
                                                                NSLog(@"Network error! Code : %ld - %@", error.code, error.description);
                                                                completionBlock(NO, @"Network error");
                                                            }
                                                            
                                                        });

                                                    }];
    
    [postTask resume];
        
}

// Get member profile (Facebook & e-mail 계정)
+ (void)getMemberProfileRequestWithCompletionBlock:(void (^)(BOOL isSuccess, NSString* result))completionBlock {
    
    // Session
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    // Request
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%ld/", API_BASE_URL, MEMBER_PROFILE_URL, [DataCenter sharedInstance].momoUserData.pk]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    // 헤더 세팅
    [request addValue:[NSString stringWithFormat:@"Token %@", [[DataCenter sharedInstance] getUserToken]] forHTTPHeaderField:@"Authorization"];
    
    request.HTTPMethod = @"GET";
    
    // Task
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                    NSLog(@"Status Code : %ld", ((NSHTTPURLResponse *)response).statusCode);
                                                    NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                                                    
                                                    NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                                                    
                                                    // 메인스레드로 돌려서 보냄
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        
                                                        if (!error) {
                                                            if (((NSHTTPURLResponse *)response).statusCode == 200) {
                                                                // Code: 200 Success
                                                                
                                                                // 데이터 파싱, 세팅
                                                                [DataCenter momoGetMemberProfileDicParsingAndUpdate:responseDic];

                                                                completionBlock(YES, nil);
                                                                
                                                            } else {
                                                                // Code: 400 ???
                                                                
                                                                // Code: 401 Unauthorized
                                                                // 토큰이 유효하지 않습니다.
                                                                // 자격 인증데이터(authentication credentials)가 제공되지 않았습니다.
                                                                
                                                                // Code: 404 Not found
                                                                // 해당 pk의 user가 존재하지 않습니다.
                                                                
                                                                [DataCenter removeMomoUserData];  // 세팅된 DB 다시 삭제
                                                                
                                                                NSLog(@"%@", [responseDic objectForKey:@"detail"]);
                                                                completionBlock(NO, [responseDic objectForKey:@"detail"]);
                                                                
                                                            }
                                                        } else {
                                                            // Network error
                                                            [DataCenter removeMomoUserData];  // 세팅된 DB 다시 삭제
                                                            NSLog(@"Network error! Code : %ld - %@", error.code, error.description);
                                                            completionBlock(NO, @"Network error");
                                                        }
                                                        
                                                    });
                                                }];
    
    [dataTask resume];

}



// Patch member profile update
+ (void)patchMemberProfileUpdateWithUsername:(NSString *)username
                              withProfileImg:(NSData *)imgData
                         withCompletionBlock:(void (^)(BOOL isSuccess, NSString *result))completionBlock {
    
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"PATCH" URLString:[NSString stringWithFormat:@"%@%@%ld/", API_BASE_URL, MEMBER_PROFILE_URL, [DataCenter sharedInstance].momoUserData.pk] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        [formData appendPartWithFormData:[username dataUsingEncoding:NSUTF8StringEncoding] name:@"username"];                       // 유저네임
        [formData appendPartWithFileData:imgData name:@"profile_img" fileName:@"profile_img.jpeg" mimeType:@"image/jpeg"];          // 프로필 사진
        
    } error:nil];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionUploadTask *uploadTask;
    
    [request setValue:[NSString stringWithFormat:@"Token %@", [[DataCenter sharedInstance] getUserToken]] forHTTPHeaderField:@"Authorization"];
    uploadTask = [manager uploadTaskWithStreamedRequest:request
                                               progress:nil
                                      completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                                          
                                          NSLog(@"Status Code : %ld", ((NSHTTPURLResponse *)response).statusCode);
                                          NSLog(@"%@", responseObject);
                                          
                                          // 메인스레드로 돌려서 보냄
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              
                                              if (!error) {
                                                  if (((NSHTTPURLResponse *)response).statusCode == 200) {
                                                      // Code: 200 Success
                                                      
                                                      // 데이터 파싱, 세팅
                                                      [DataCenter momoGetMemberProfileDicParsingAndUpdate:responseObject];
                                                      
                                                      completionBlock(YES, @"Code: 200 Success");
                                                      
                                                  } else {
                                                      // Code: 413 Request Entity Too Large
                                                      // Code: 500 BAD REQUEST
                                                      
                                                      completionBlock(NO, @"BAD REQUEST");
                                                      
                                                  }
                                              } else {
                                                  // Network error
                                                  NSLog(@"Network error! Code : %ld - %@", error.code, error.description);
                                                  completionBlock(NO, @"Network error");
                                              }
                                          });
                                          
                                      }];
    
    [uploadTask resume];
    
}









//********************************************************//
//                        Map API                         //
//********************************************************//


// Map Create
+ (void)createMapRequestWithMapname:(NSString *)mapname
                    withDescription:(NSString *)description
                      withIsPrivate:(BOOL)is_private
                withCompletionBlock:(void (^)(BOOL isSuccess, NSString* result))completionBlock {
    
    // Session
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    // Request
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", API_BASE_URL, MAP_URL]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];

    // 헤더 세팅
    [request addValue:[NSString stringWithFormat:@"Token %@", [[DataCenter sharedInstance] getUserToken]] forHTTPHeaderField:@"Authorization"];

    // 바디 세팅
    request.HTTPBody = [[NSString stringWithFormat:@"map_name=%@&description=%@&is_private=%d", mapname, description, is_private] dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPMethod = @"POST";
    
    // Task
    NSURLSessionUploadTask *postTask = [session uploadTaskWithRequest:request
                                                             fromData:nil
                                                    completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                        
                                                        NSLog(@"Status Code : %ld", ((NSHTTPURLResponse *)response).statusCode);
                                                        NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                                                        
                                                        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];

                                                        
                                                        // 메인스레드로 돌려서 보냄
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            
                                                            if (!error) {
                                                                if (((NSHTTPURLResponse *)response).statusCode == 201) {
                                                                    // Code: 201 CREATED
                                                                    NSLog(@"Map Create Success");
                                                                    
                                                                    // 맵 데이터 파싱 및 저장
                                                                    [DataCenter createMapWithMomoMapCreateDic:responseDic];
                                                                    
                                                                    completionBlock(YES, nil);
                                                                    
                                                                    
                                                                } else {
                                                                    // Code: 400 BAD REQUEST
                                                                    NSLog(@"Map Create Fail");
                                                                    
                                                                    completionBlock(NO, [responseDic objectForKey:@"detail"]);
                                                                    
                                                                }
                                                            } else {
                                                                // Network error
                                                                NSLog(@"Network error! Code : %ld - %@", error.code, error.description);
                                                                completionBlock(NO, @"Network error");
                                                            }
                                                        });
                                                        
                                                    }];
    
    [postTask resume];
}


// Map Update
+ (void)updateMapRequestWithMapPK:(NSInteger)map_pk
                      withMapname:(NSString *)mapname
                  withDescription:(NSString *)description
                    withIsPrivate:(BOOL)is_private
              withCompletionBlock:(void (^)(BOOL isSuccess, NSString* result))completionBlock {
    
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"PATCH" URLString:[NSString stringWithFormat:@"%@%@%ld/", API_BASE_URL, MAP_URL, map_pk] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        [formData appendPartWithFormData:[mapname dataUsingEncoding:NSUTF8StringEncoding] name:@"map_name"];                                            // map_name
        [formData appendPartWithFormData:[description dataUsingEncoding:NSUTF8StringEncoding] name:@"description"];                                     // description
        [formData appendPartWithFormData:[[NSString stringWithFormat:@"%d", is_private] dataUsingEncoding:NSUTF8StringEncoding] name:@"is_private"];    // is_private
        
    } error:nil];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionUploadTask *uploadTask;
    
    [request setValue:[NSString stringWithFormat:@"Token %@", [[DataCenter sharedInstance] getUserToken]] forHTTPHeaderField:@"Authorization"];
    uploadTask = [manager uploadTaskWithStreamedRequest:request
                                               progress:nil
                                      completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                                          
                                          NSLog(@"Status Code : %ld", ((NSHTTPURLResponse *)response).statusCode);
                                          NSLog(@"%@", responseObject);
                                          
                                          
                                          // 메인스레드로 돌려서 보냄
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              
                                              if (!error) {
                                                  if (((NSHTTPURLResponse *)response).statusCode == 200) {
                                                      // Code: ??
                                                      NSLog(@"Map Update Success");
                                                      
                                                      // 맵 수정
                                                      [DataCenter updateMapWithMomoMapCreateDic:responseObject];
                                                      
                                                      completionBlock(YES, nil);
                                                      
                                                      
                                                  } else {
                                                      // Code: 400 BAD REQUEST
                                                      NSLog(@"Map Update Fail");
                                                      
                                                      completionBlock(NO, [responseObject objectForKey:@"detail"]);
                                                      
                                                  }
                                              } else {
                                                  // Network error
                                                  NSLog(@"Network error! Code : %ld - %@", error.code, error.description);
                                                  completionBlock(NO, @"Network error");
                                              }
                                          });

                                      }];
    
    [uploadTask resume];

}



// Map Delete
+ (void)deleteMapRequestWithMapData:(MomoMapDataSet *)mapData
                withCompletionBlock:(void (^)(BOOL isSuccess, NSString* result))completionBlock {
    
    // Session
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    // Request
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%ld/", API_BASE_URL, MAP_URL, mapData.pk]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    // 헤더 세팅
    [request addValue:[NSString stringWithFormat:@"Token %@", [[DataCenter sharedInstance] getUserToken]] forHTTPHeaderField:@"Authorization"];
    
    request.HTTPMethod = @"DELETE";
    
    // Task
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                    
                                                        NSLog(@"Status Code : %ld", ((NSHTTPURLResponse *)response).statusCode);
                                                        NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);                                                        
                                                        
                                                        // 메인스레드로 돌려서 보냄
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            
                                                            if (!error) {
                                                                if (((NSHTTPURLResponse *)response).statusCode == 204) {
                                                                    // Code: 204 No Content
                                                                    NSLog(@"Map Delete Success");
                                                                    
                                                                    // 맵 삭제
                                                                    [DataCenter deleteMapData:mapData];
                                                                    completionBlock(YES, nil);
                                                                    
                                                                    
                                                                } else {
                                                                    NSLog(@"Map Delete Fail");
                                                                    
                                                                    NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                                                                    
                                                                    completionBlock(NO, [responseDic objectForKey:@"detail"]);
                                                                
                                                                }
                                                            } else {
                                                                // Network error
                                                                NSLog(@"Network error! Code : %ld - %@", error.code, error.description);
                                                                completionBlock(NO, @"Network error");
                                                            }
                                                        });
                                                        
                                                    }];
    
    [dataTask resume];
}


//********************************************************//
//                        Pin API                         //
//********************************************************//


// Pin Create
+ (void)createPinRequestWithPinname:(NSString *)pinname
                          withMapPK:(NSInteger)map_pk
                          withLabel:(NSInteger)pinLabel
                            withLat:(CGFloat)lat
                            withLng:(CGFloat)lng
                    withDescription:(NSString *)description
                withCompletionBlock:(void (^)(BOOL isSuccess, NSString* result))completionBlock {
    
    // Session
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    // Request
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", API_BASE_URL, PIN_URL]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    // 헤더 세팅
    [request addValue:[NSString stringWithFormat:@"Token %@", [[DataCenter sharedInstance] getUserToken]] forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    // 바디 세팅
    NSString *pinJson = [NSString stringWithFormat:@"\"pin\":{\"pin_name\":\"%@\",\"map\":\"%ld\",\"pin_label\":\"%ld\"}", pinname, map_pk, pinLabel];
    NSString *placeJson = [NSString stringWithFormat:@"\"place\":{\"lat\":\"%lf\",\"lng\":\"%lf\"}", lat, lng];
    NSData *paramData = [[NSString stringWithFormat:@"{%@,%@}", pinJson, placeJson] dataUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"pin Json data : %@", [NSString stringWithFormat:@"{%@,%@}", pinJson, placeJson]);

    request.HTTPBody = paramData;
    request.HTTPMethod = @"POST";
    
    // Task
    NSURLSessionUploadTask *postTask = [session uploadTaskWithRequest:request
                                                             fromData:nil
                                                    completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                        
                                                        NSLog(@"Status Code : %ld", ((NSHTTPURLResponse *)response).statusCode);
                                                        NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                                                        
                                                        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                                                        
                                                        
                                                        // 메인스레드로 돌려서 보냄
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            
                                                            if (!error) {
                                                                if (((NSHTTPURLResponse *)response).statusCode == 201) {
                                                                    // Code: 201 CREATED
                                                                    NSLog(@"Pin Create Success");
                                                                    
                                                                    // 핀 데이터 파싱 및 저장
                                                                    [DataCenter createPinWithMomoPinCreateDic:responseDic];
                                                                    
                                                                    completionBlock(YES, nil);
                                                                    
                                                                    
                                                                } else {
                                                                    // Code: 400 BAD REQUEST
                                                                    NSLog(@"Pin Create Fail");
                                                                    
                                                                    completionBlock(NO, [responseDic objectForKey:@"detail"]);
                                                                    
                                                                }
                                                            } else {
                                                                // Network error
                                                                NSLog(@"Network error! Code : %ld - %@", error.code, error.description);
                                                                completionBlock(NO, @"Network error");
                                                            }
                                                        });
                                                        
                                                    }];
    
    [postTask resume];
}

// Pin Update
+ (void)updatePinRequestWithPinPK:(NSInteger)pin_pk
                      withPinname:(NSString *)pinname
                        withLabel:(NSInteger)pinLabel
                        withMapPK:(NSInteger)map_pk
              withCompletionBlock:(void (^)(BOOL isSuccess, NSString* result))completionBlock {
    
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"PATCH" URLString:[NSString stringWithFormat:@"%@%@%ld/", API_BASE_URL, PIN_URL, pin_pk] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        [formData appendPartWithFormData:[pinname dataUsingEncoding:NSUTF8StringEncoding] name:@"pin_name"];                                            // pin_name
        [formData appendPartWithFormData:[[NSString stringWithFormat:@"%ld", pinLabel] dataUsingEncoding:NSUTF8StringEncoding] name:@"pin_label"];      // pin_label
        [formData appendPartWithFormData:[[NSString stringWithFormat:@"%ld", map_pk] dataUsingEncoding:NSUTF8StringEncoding] name:@"map"];              // map_pk
        
    } error:nil];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionUploadTask *uploadTask;
    
    [request setValue:[NSString stringWithFormat:@"Token %@", [[DataCenter sharedInstance] getUserToken]] forHTTPHeaderField:@"Authorization"];
    uploadTask = [manager uploadTaskWithStreamedRequest:request
                                               progress:nil
                                      completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                                          
                                          NSLog(@"Status Code : %ld", ((NSHTTPURLResponse *)response).statusCode);
                                          NSLog(@"%@", responseObject);
                                          
                                          // 메인스레드로 돌려서 보냄
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              
                                              if (!error) {
                                                  if (((NSHTTPURLResponse *)response).statusCode == 200) {
                                                      // Code: ??
                                                      NSLog(@"Pin Update Success");
                                                      
                                                      // 핀 수정
                                                      [DataCenter updatePinWithMomoPinCreateDic:responseObject];
                                                      
                                                      completionBlock(YES, nil);
                                                      
                                                      
                                                  } else {
                                                      // Code: 400 BAD REQUEST
                                                      NSLog(@"Pin Update Fail");
                                                      
                                                      completionBlock(NO, [responseObject objectForKey:@"detail"]);
                                                      
                                                  }
                                              } else {
                                                  // Network error
                                                  NSLog(@"Network error! Code : %ld - %@", error.code, error.description);
                                                  completionBlock(NO, @"Network error");
                                              }
                                          });
                                          
                                      }];
    
    [uploadTask resume];
    
}



// Pin Delete
+ (void)deletePinRequestWithPinData:(MomoPinDataSet *)pinData
                withCompletionBlock:(void (^)(BOOL isSuccess, NSString* result))completionBlock {
    
    // Session
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    // Request
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%ld/", API_BASE_URL, PIN_URL, pinData.pk]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    // 헤더 세팅
    [request addValue:[NSString stringWithFormat:@"Token %@", [[DataCenter sharedInstance] getUserToken]] forHTTPHeaderField:@"Authorization"];
    
    request.HTTPMethod = @"DELETE";
    
    // Task
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                    
                                                    NSLog(@"Status Code : %ld", ((NSHTTPURLResponse *)response).statusCode);
                                                    NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                                                    
                                                    // 메인스레드로 돌려서 보냄
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        
                                                        if (!error) {
                                                            if (((NSHTTPURLResponse *)response).statusCode == 204) {
                                                                // Code: 204 No Content
                                                                NSLog(@"Pin Delete Success");
                                                                
                                                                // 핀 삭제
                                                                [DataCenter deletePinData:pinData];
                                                                completionBlock(YES, nil);
                                                                
                                                                
                                                            } else {
                                                                NSLog(@"Pin Delete Fail");
                                                                
                                                                NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                                                                
                                                                completionBlock(NO, [responseDic objectForKey:@"detail"]);
                                                                
                                                            }
                                                        } else {
                                                            // Network error
                                                            NSLog(@"Network error! Code : %ld - %@", error.code, error.description);
                                                            completionBlock(NO, @"Network error");
                                                        }
                                                    });
                                                    
                                                }];
    
    [dataTask resume];
}





//********************************************************//
//                        Post API                        //
//********************************************************//


// Post Create
+ (void)createPostRequestWithPinPK:(NSInteger)pin_pk
                     withPhotoData:(NSData *)photoData
                   withDescription:(NSString *)description
               withCompletionBlock:(void (^)(BOOL isSuccess, NSString* result))completionBlock {
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:[NSString stringWithFormat:@"%@%@", API_BASE_URL, POST_URL] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        [formData appendPartWithFormData:[[NSString stringWithFormat:@"%ld", pin_pk] dataUsingEncoding:NSUTF8StringEncoding] name:@"pin"];
        
        if ([photoData length]) {
            // 사진이 있는 경우
            [formData appendPartWithFileData:photoData name:@"photo" fileName:@"photo_image.jpeg" mimeType:@"image/jpeg"];
        }
        if ([description length]) {
            // 글이 있는 경우
            [formData appendPartWithFormData:[description dataUsingEncoding:NSUTF8StringEncoding] name:@"description"];
        }
        
    } error:nil];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionUploadTask *uploadTask;
    
    [request setValue:[NSString stringWithFormat:@"Token %@", [[DataCenter sharedInstance] getUserToken]] forHTTPHeaderField:@"Authorization"];
    uploadTask = [manager uploadTaskWithStreamedRequest:request
                                               progress:nil
                                      completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                                          
                                          NSLog(@"Status Code : %ld", ((NSHTTPURLResponse *)response).statusCode);
                                          NSLog(@"%@", responseObject);
                        
                                          // 메인스레드로 돌려서 보냄
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              
                                              if (!error) {
                                                  if (((NSHTTPURLResponse *)response).statusCode == 201) {
                                                      // Code: 201 CREATED
                                                      NSLog(@"Post Create Success");
                                                      
                                                      // 포스트 데이터 파싱 및 저장
                                                      [DataCenter createPostWithMomoPostCreateDic:responseObject];
                                                      
                                                      completionBlock(YES, nil);
                                                      
                                                      
                                                  } else {
                                                      NSLog(@"Post Create Fail");
                                                      
                                                      completionBlock(NO, [responseObject objectForKey:@"detail"]);
                                                      
                                                  }
                                              } else {
                                                  // Network error
                                                  NSLog(@"Network error! Code : %ld - %@", error.code, error.description);
                                                  completionBlock(NO, @"Network error");
                                              }
                                          });
                                          
                                      }];
    
    [uploadTask resume];
    
    
    // 기존 안되던 코드
    // 이미지 넣는 부분 공부 필요
//    // Session
//    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
//
//    // Request
//    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", API_BASE_URL, POST_URL]];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//
//    // 헤더 세팅
//    [request addValue:[NSString stringWithFormat:@"Token %@", [[DataCenter sharedInstance] getUserToken]] forHTTPHeaderField:@"Authorization"];
//
//    // 바디 세팅
//    if ([photoData length] && [description length]) {
//        // 사진, 글 둘 다 있는 경우
//        request.HTTPBody = [[NSString stringWithFormat:@"pin=%ld&photo=%@&description=%@", pin_pk, photoData, description] dataUsingEncoding:NSUTF8StringEncoding];
//    } else if ([photoData length]) {
//        // 사진만 있는 경우
//        request.HTTPBody = [[NSString stringWithFormat:@"pin=%ld&photo=%@", pin_pk, photoData] dataUsingEncoding:NSUTF8StringEncoding];
//    } else {
//        // 글만 있는 경우
//        request.HTTPBody = [[NSString stringWithFormat:@"pin=%ld&description=%@", pin_pk, description] dataUsingEncoding:NSUTF8StringEncoding];
//    }
//    request.HTTPMethod = @"POST";
//    
//    // Task
//    NSURLSessionUploadTask *postTask = [session uploadTaskWithRequest:request
//                                                             fromData:nil
//                                                    completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//                                                        
//                                                        NSLog(@"Status Code : %ld", ((NSHTTPURLResponse *)response).statusCode);
//                                                        NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
//                                                        
//                                                        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
//                                                        
//                                                        
//                                                        // 메인스레드로 돌려서 보냄
//                                                        dispatch_async(dispatch_get_main_queue(), ^{
//                                                            
//                                                            if (!error) {
//                                                                if (((NSHTTPURLResponse *)response).statusCode == 201) {
//                                                                    // Code: 201 CREATED
//                                                                    NSLog(@"Post Create Success");
//                                                                    
//                                                                    // 포스트 데이터 파싱 및 저장
//                                                                    [DataCenter createPostWithMomoPostCreateDic:responseDic];
//                                                                    
//                                                                    completionBlock(YES, nil);
//                                                                    
//                                                                    
//                                                                } else {
//                                                                    NSLog(@"Post Create Fail");
//                                                                    
//                                                                    completionBlock(NO, [responseDic objectForKey:@"detail"]);
//                                                                    
//                                                                }
//                                                            } else {
//                                                                // Network error
//                                                                NSLog(@"Network error! Code : %ld - %@", error.code, error.description);
//                                                                completionBlock(NO, @"Network error");
//                                                            }
//                                                        });
//                                                        
//                                                    }];
//    
//    [postTask resume];
}


// Post Update
+ (void)updatePostRequestWithPostPK:(NSInteger)post_pk
                          WithPinPK:(NSInteger)pin_pk
                      withPhotoData:(NSData *)photoData
                    withDescription:(NSString *)description
                withCompletionBlock:(void (^)(BOOL isSuccess, NSString* result))completionBlock {

    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"PATCH" URLString:[NSString stringWithFormat:@"%@%@%ld/", API_BASE_URL, POST_URL, post_pk] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {

        
        [formData appendPartWithFormData:[[NSString stringWithFormat:@"%ld", pin_pk] dataUsingEncoding:NSUTF8StringEncoding] name:@"pin"];      // pin_pk

        if ([photoData length]) {
            // 사진이 있는 경우
            [formData appendPartWithFileData:photoData name:@"photo" fileName:@"photo_image.jpeg" mimeType:@"image/jpeg"];
        }
        if ([description length]) {
            // 글이 있는 경우
            [formData appendPartWithFormData:[description dataUsingEncoding:NSUTF8StringEncoding] name:@"description"];
        }
        
    } error:nil];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionUploadTask *uploadTask;
    
    [request setValue:[NSString stringWithFormat:@"Token %@", [[DataCenter sharedInstance] getUserToken]] forHTTPHeaderField:@"Authorization"];
    uploadTask = [manager uploadTaskWithStreamedRequest:request
                                               progress:nil
                                      completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                                          
                                          NSLog(@"Status Code : %ld", ((NSHTTPURLResponse *)response).statusCode);
                                          NSLog(@"%@", responseObject);
                                          
                                          
                                          // 메인스레드로 돌려서 보냄
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              
                                              if (!error) {
                                                  if (((NSHTTPURLResponse *)response).statusCode == 200) {
                                                      // Code: ??
                                                      NSLog(@"Post Update Success");
                                                      
                                                      // 포스트 수정
                                                      [DataCenter updatePostWithMomoPostCreateDic:responseObject];
                                                      
                                                      completionBlock(YES, nil);
                                                      
                                                      
                                                  } else {
                                                      // Code: 400 BAD REQUEST
                                                      NSLog(@"Post Update Fail");
                                                      
                                                      completionBlock(NO, [responseObject objectForKey:@"detail"]);
                                                      
                                                  }
                                              } else {
                                                  // Network error
                                                  NSLog(@"Network error! Code : %ld - %@", error.code, error.description);
                                                  completionBlock(NO, @"Network error");
                                              }
                                          });
                                          
                                      }];
    
    [uploadTask resume];
    
}




// Post Delete
+ (void)deletePostRequestWithPostData:(MomoPostDataSet *)postData
                  withCompletionBlock:(void (^)(BOOL isSuccess, NSString* result))completionBlock {
    
    // Session
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    // Request
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%ld/", API_BASE_URL, POST_URL, postData.pk]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    // 헤더 세팅
    [request addValue:[NSString stringWithFormat:@"Token %@", [[DataCenter sharedInstance] getUserToken]] forHTTPHeaderField:@"Authorization"];
    
    request.HTTPMethod = @"DELETE";
    
    // Task
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                    
                                                    NSLog(@"Status Code : %ld", ((NSHTTPURLResponse *)response).statusCode);
                                                    NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                                                    
                                                    // 메인스레드로 돌려서 보냄
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        
                                                        if (!error) {
                                                            if (((NSHTTPURLResponse *)response).statusCode == 204) {
                                                                // Code: 204 No Content
                                                                NSLog(@"Post Delete Success");
                                                                
                                                                // 포스트 삭제
                                                                [DataCenter deletePostData:postData];
                                                                completionBlock(YES, nil);
                                                                
                                                                
                                                            } else {
                                                                NSLog(@"Post Delete Fail");
                                                                
                                                                NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                                                                
                                                                completionBlock(NO, [responseDic objectForKey:@"detail"]);
                                                                
                                                            }
                                                        } else {
                                                            // Network error
                                                            NSLog(@"Network error! Code : %ld - %@", error.code, error.description);
                                                            completionBlock(NO, @"Network error");
                                                        }
                                                    });
                                                    
                                                }];
    
    [dataTask resume];
}





@end
