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
                                                            
                                                            [self getEmailUserProfileInfosWithToken:[responseDic objectForKey:@"key"] withCompletionBlock:^(MomoUserDataSet *momoUserData) {
                                                                
                                                                [DataCenter sharedInstance].momoUserData = momoUserData;
                                                                
                                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                                    [DataCenter saveMomoUserData];  // DB저장
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
                                                            
                                                            [self getEmailUserProfileInfosWithToken:[responseDic objectForKey:@"key"] withCompletionBlock:^(MomoUserDataSet *momoUserData) {
                                                                
                                                                [DataCenter sharedInstance].momoUserData = momoUserData;
                                                                
                                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                                    [DataCenter saveMomoUserData];  // DB저장
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

    // 페북 로그인 -> 앱 종료 -> 다시 실행시 페북 로그인 재인증 아직 미구현
    if ([FBSDKAccessToken currentAccessToken]) { // Facebook 계정
        NSLog(@"Facebook Log out");
        
        [FacebookModule fbLogOut];
        [DataCenter removeMomoUserData];       // 토큰을 비롯한 유저 데이터 삭제

        completionBlock(YES, nil);
        
    } else if (TRUE) {
        // 앱 재실행시 있는 토큰으로 자동 인증 및 로그인 미구현.
        // 일단 로그아웃은 서버 안거치고 무조건 토큰 삭제
        NSLog(@"로그아웃, token : %@", [DataCenter getUserToken]);
        [DataCenter removeMomoUserData];           // 토큰을 비롯한 유저 데이터 삭제
        NSLog(@"초기화 완료 -> token : %@", [DataCenter getUserToken]);
        
        completionBlock(YES, nil);
        
    } else {        // e-mail 계정
        NSLog(@"e-mail account Log out");

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
                                                                [DataCenter removeMomoUserData];           // 토큰을 비롯한 유저 데이터 삭제
                                                                NSLog(@"초기화 완료 -> token : %@", [DataCenter getUserToken]);
                                                                
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


// 이메일 계정, 서버로부터 유저 프로필 정보들 받아오는 메서드
+ (void)getEmailUserProfileInfosWithToken:(NSString *)token withCompletionBlock:(void (^)(MomoUserDataSet *momoUserData))completionBlock {
    NSLog(@"getUserProfileInfosWithToken, token : %@", token);
    
    MomoUserDataSet *momoUserData = [[MomoUserDataSet alloc] init];
    
    momoUserData.user_token = token;
    
    // 서버로부터 유저 정보 받아와 세팅할 부분
    
    [self getUserMapDataWithCompletionBlock:^(RLMArray<MomoMapDataSet *><MomoMapDataSet> *user_map_list) {
        momoUserData.user_map_list = user_map_list;
        completionBlock(momoUserData);
    }];
}



// 서버로부터 유저 지도리스트 받아오는 메서드
+ (void)getUserMapDataWithCompletionBlock:(void (^)(RLMArray<MomoMapDataSet *><MomoMapDataSet> *user_map_list))completionBlock {
    NSLog(@"getUserDataWithCompletionBlock");
    
    // 서버로부터 유저 지도리스트 등 받아와 세팅할 부분
    // 일단 더미로 넣겠음

    NSArray *mapArr = @[@[@"지도명", @"지도 설명", @1],   // 지도명, 지도설명, 공개설정(0: 공개 , 1 : 비공개)
                        @[@"패캠 주변 맛집", @"가로수길 근천데 맛집 잘 없는거 같은건 기분탓인가??????????????????????", @0],
                        @[@"서울 맛집 리스트", @"yummy yummy👍", @1],
                        @[@"제주도를 가보자", @"꿀잼", @0],
                        @[@"광화문-경복궁-서촌", @"오피스 라이프를 빛내주는 곳들 :)", @0],
                        @[@"이태원 맥주집", @"준영이형 마음의 고향을 파헤쳐보자", @0],
                        @[@"낚시", @"", @1],
                        @[@"엑소 투어⚡️", @"엑소 따라 여행 간다", @0],
                        @[@"수도권 마스킹 or 와이드스크린 영화관", @"🍿", @1]];
    

    
    NSArray *pinArr = @[@[@"핀명", @"핀주소", @4, @37.517181f, @127.028488f],   // 핀명, 핀주소, 라벨(0~5), 위도, 경도
                        @[@"패스트캠퍼스", @"패캠패캠", @3, @37.515602, @127.021402],
                        @[@"이케아", @"이케아 👍", @2, @37.423480, @126.882591],
                        @[@"롯데월드", @"꿀잼", @3, @37.511120, @127.098328],
                        @[@"강남역", @"항상 사람 많은듯", @3, @37.498023, @127.027417],
                        @[@"발리 슈퍼스토어", @"준영이형의 마음의 고향", @1, @37.548755, @126.916777],
                        @[@"화곡 2동 주민센터", @"한선이형 동네", @3, @37.531612, @126.854423],
                        @[@"나들목", @"맛있음 ㅋㅋ", @0, @37.517116, @127.023943]];
    
    MomoUserDataSet *userData = [[MomoUserDataSet alloc] init];

    for (NSInteger i = 0 ; i < mapArr.count ; i++) {
        MomoMapDataSet *mapData = [[MomoMapDataSet alloc] init];
        [userData.user_map_list addObject:mapData];
        
        mapData.map_name = mapArr[i][0];
        mapData.map_description = mapArr[i][1];
        mapData.map_is_private = [(NSNumber *)mapArr[i][2] boolValue];
        
        for (NSInteger j = 0 ; j < pinArr.count ; j++) {
            MomoPinDataSet *pinData = [[MomoPinDataSet alloc] init];
            [mapData.map_pin_list addObject:pinData];
                        
            pinData.pin_name = pinArr[j][0];
            pinData.pin_label = [(NSNumber *)pinArr[j][2] integerValue];
            
            MomoPlaceDataSet *placeData = [[MomoPlaceDataSet alloc] init];
            pinData.pin_place = placeData;
            placeData.place_lat = [(NSNumber *)pinArr[j][3] doubleValue];
            placeData.place_lng = [(NSNumber *)pinArr[j][4] doubleValue];
        }
    }

    completionBlock(userData.user_map_list);
}



@end
