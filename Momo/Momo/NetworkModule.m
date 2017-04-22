//
//  NetworkModule.m
//  Momo
//
//  Created by Jeheon Choi on 2017. 3. 27..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import "NetworkModule.h"


static NSString *const API_BASE_URL         = @"https://momo.kizmo04.com";

static NSString *const SIGN_UP_URL          = @"/api/member/signup/";
static NSString *const LOG_IN_URL           = @"/api/member/login/";
static NSString *const LOG_OUT_URL          = @"/api/member/logout/";
static NSString *const MEMBER_PROFILE_URL   = @"/api/member/";    // + /{user_id}/      user_id -> pk


static NSString *const MAP_URL              = @"/api/map/";
static NSString *const PIN_URL              = @"/api/pin/";



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
    
    request.HTTPBody = [[NSString stringWithFormat:@"username=%@&password=%@&email=%@", username, password, email] dataUsingEncoding:NSUTF8StringEncoding];
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
                                                                    NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                                                                    
                                                                    if ([responseDic objectForKey:@"username"]) {
                                                                        // momo user의 username은/는 이미 존재합니다.
                                                                        NSLog(@"%@", [responseDic objectForKey:@"username"][0]);
                                                                        completionBlock(NO, [responseDic objectForKey:@"username"][0]);
                                                                        
                                                                    } else {
                                                                        // 유효한 이메일 주소를 입력하십시오.
                                                                        NSLog(@"%@", [responseDic objectForKey:@"email"][0]);
                                                                        completionBlock(NO, [responseDic objectForKey:@"email"][0]);
                                                                    }
                                                                    
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
    
    [dataTask resume];

}



//// 서버로부터 유저 지도정보 패치하는 메서드
//+ (void)fetchUserMapData {
//    NSLog(@"fetchUserMapData");
//    
//    // 서버로부터 유저 지도리스트 등 받아와 세팅할 부분
//    // 일단 더미로 넣겠음
//
//    NSArray *mapArr = @[@[@"지도명", @"지도 설명", @1],   // 지도명, 지도설명, 공개설정(0: 공개 , 1 : 비공개)
//                        @[@"패캠 주변 맛집", @"가로수길 근천데 맛집 잘 없는거 같은건 기분탓인가??????????????????????", @0],
//                        @[@"서울 맛집 리스트", @"yummy yummy👍", @1],
//                        @[@"제주도를 가보자", @"꿀잼", @0],
//                        @[@"광화문-경복궁-서촌", @"오피스 라이프를 빛내주는 곳들 :)", @0],
//                        @[@"이태원 맥주집", @"준영이형 마음의 고향을 파헤쳐보자", @0],
//                        @[@"낚시", @"", @1],
//                        @[@"엑소 투어⚡️", @"엑소 따라 여행 간다", @0],
//                        @[@"수도권 마스킹 or 와이드스크린 영화관", @"🍿", @1]];
//    
//
//    
//    NSArray *pinArr = @[@[@"핀명", @"핀주소", @"핀설명", @4, @37.517181f, @127.028488f],   // 핀명, 핀주소, 핀설명, 라벨(0~5), 위도, 경도
//                        @[@"패스트캠퍼스", @"서울특별시 강남구 논현1동", @"패캠패캠", @3, @37.515602, @127.021402],
//                        @[@"이케아", @"경기도 광명시 소하2동 일직로 17", @"이케아 👍", @2, @37.423480, @126.882591],
//                        @[@"롯데월드", @"서울특별시 송파구 잠실3동 올림픽로 240", @"꿀잼", @3, @37.511120, @127.098328],
//                        @[@"강남역", @"서울특별시 역삼1동", @"항상 사람 많은듯", @3, @37.498023, @127.027417],
//                        @[@"발리 슈퍼스토어", @"서울특별시 마포구 서교동 양화로6길 45", @"준영이형의 마음의 고향", @1, @37.548755, @126.916777],
//                        @[@"화곡 2동 주민센터", @"서울특별시 강서구 화곡2동 곰달래로37길 13", @"한선이형 동네", @3, @37.531612, @126.854423],
//                        @[@"나들목", @"서울특별시 강남구 논현동 5-16", @"맛있음 ㅋㅋ", @1, @37.517116, @127.023943],
//                        @[@"나들목2", @"서울특별시 강남구 논현동 5-16", @"이 핀은 테스트 맛있음 ㅋㅋ", @1, @37.517126, @127.023743],
//                        @[@"스타벅스 신사역점", @"서울특별시 강남구 논현동 1-3", @"좁은데, 사람도 많아..", @0, @37.516224, @127.020653]];
//    
//    
//    
//    RLMRealm *realm = [RLMRealm defaultRealm];
//    [realm transactionWithBlock:^{
//
//        for (NSInteger i = 0 ; i < mapArr.count ; i++) {
//            MomoMapDataSet *mapData = [[MomoMapDataSet alloc] init];
//            [[DataCenter sharedInstance].momoUserData.user_map_list addObject:mapData];
//            
//            mapData.pk = i;
//            mapData.map_name = mapArr[i][0];
//            if (![mapArr[i][1] isEqualToString:@""]) {  // 설명 비었을 경우 테스트
//                mapData.map_description = mapArr[i][1];
//            }
//            mapData.map_is_private = [(NSNumber *)mapArr[i][2] boolValue];
//            
//            if (i == 0) {
//                // 0번 지도만 핀 등록
//                for (NSInteger j = 0 ; j < pinArr.count ; j++) {
//                    MomoPinDataSet *pinData = [[MomoPinDataSet alloc] init];
//                    [mapData.map_pin_list addObject:pinData];
//                    
//                    pinData.pk = j;
//                    pinData.pin_name = pinArr[j][0];
////                    pinData.pin_description = pinArr[j][2];
//                    pinData.pin_label = [(NSNumber *)pinArr[j][3] integerValue];
//                    pinData.pin_map_pk = mapData.pk;
//                    
//                    MomoPlaceDataSet *placeData = [[MomoPlaceDataSet alloc] init];
//                    pinData.pin_place = placeData;
//                    
//                    placeData.pk = j;
//                    placeData.place_address = pinArr[j][1];
//                    placeData.place_lat = [(NSNumber *)pinArr[j][4] doubleValue];
//                    placeData.place_lng = [(NSNumber *)pinArr[j][5] doubleValue];
//                }
//            }
//        }
//    }];
//}


// Patch member profile update
+ (void)patchMemberProfileUpdateWithUsername:(NSString *)username
                              withProfileImg:(NSData *)imgData
                         withCompletionBlock:(void (^)(BOOL isSuccess, NSString *result))completionBlock {
    
    // Session
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    // Request
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%ld/", API_BASE_URL, MEMBER_PROFILE_URL, [DataCenter sharedInstance].momoUserData.pk]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];

    // 헤더 세팅
    [request addValue:[NSString stringWithFormat:@"Token %@", [[DataCenter sharedInstance] getUserToken]] forHTTPHeaderField:@"Authorization"];

    // 바디 세팅 : Update username & profile_img
    request.HTTPBody = [[NSString stringWithFormat:@"username=%@&profile_img=%@", username, imgData] dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPMethod = @"PATCH";
    
    // Task
    NSURLSessionUploadTask *patchTask = [session uploadTaskWithRequest:request
                                                              fromData:nil
                                                     completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                         
                                                         NSLog(@"Status Code : %ld", ((NSHTTPURLResponse *)response).statusCode);
                                                         NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                                                         
                                                         // 메인스레드로 돌려서 보냄
                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                             
                                                             if (!error) {
                                                                 if (((NSHTTPURLResponse *)response).statusCode == 200) {
                                                                     // Code: 200 Success
                                                                     
                                                                     NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                                                                     
                                                                     // realm transaction
                                                                     RLMRealm *realm = [RLMRealm defaultRealm];
                                                                     [realm transactionWithBlock:^{
                                                                         if ([responseDic objectForKey:@"username"]) {
                                                                             [DataCenter sharedInstance].momoUserData.user_username = [responseDic objectForKey:@"username"];
                                                                         }
                                                                         if ([[responseDic objectForKey:@"profile_img"] objectForKey:@"full_size"]) {
                                                                             [DataCenter sharedInstance].momoUserData.user_profile_image_url = [[responseDic objectForKey:@"profile_img"] objectForKey:@"full_size"];
                                                                         }
                                                                     }];
                                                                     
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
    
    [patchTask resume];
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
    
    // Session
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    // Request
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%ld/", API_BASE_URL, MAP_URL, map_pk]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    // 헤더 세팅
    [request addValue:[NSString stringWithFormat:@"Token %@", [[DataCenter sharedInstance] getUserToken]] forHTTPHeaderField:@"Authorization"];
    
    // 바디 세팅
    request.HTTPBody = [[NSString stringWithFormat:@"map_name=%@&description=%@&is_private=%d", mapname, description, is_private] dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPMethod = @"PATCH";
    
    // Task
    NSURLSessionUploadTask *patchTask = [session uploadTaskWithRequest:request
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
                                                                     
                                                                     // 맵 수정
                                                                     [DataCenter updateMapWithMomoMapCreateDic:responseDic];
                                                                     
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
    
    [patchTask resume];
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
+ (void)updatePinRequestWithMapPK:(NSInteger)map_pk
                      withMapname:(NSString *)mapname
                  withDescription:(NSString *)description
                    withIsPrivate:(BOOL)is_private
              withCompletionBlock:(void (^)(BOOL isSuccess, NSString* result))completionBlock {
    
    // Session
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    // Request
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%ld/", API_BASE_URL, MAP_URL, map_pk]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    // 헤더 세팅
    [request addValue:[NSString stringWithFormat:@"Token %@", [[DataCenter sharedInstance] getUserToken]] forHTTPHeaderField:@"Authorization"];
    
    // 바디 세팅
    request.HTTPBody = [[NSString stringWithFormat:@"map_name=%@&description=%@&is_private=%d", mapname, description, is_private] dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPMethod = @"PATCH";
    
    // Task
    NSURLSessionUploadTask *patchTask = [session uploadTaskWithRequest:request
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
                                                                     
                                                                     // 맵 수정
                                                                     [DataCenter updateMapWithMomoMapCreateDic:responseDic];
                                                                     
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
    
    [patchTask resume];
}



// Pin Delete
+ (void)deletePinRequestWithMapData:(MomoMapDataSet *)mapData
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





@end
