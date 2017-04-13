//
//  FacebookModule.m
//  Momo
//
//  Created by Jeheon Choi on 2017. 4. 11..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import "FacebookModule.h"

@implementation FacebookModule

// Facebook account -------------------------------//
#pragma mark - Facebook Auth Account Methods

// FBSDKLoginManager Singleton Instance
+ (FBSDKLoginManager *)sharedFBLoginManeger {
    
    static FBSDKLoginManager *fbLoginManeger;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fbLoginManeger = [[FBSDKLoginManager alloc] init];
    });
    
    return fbLoginManeger;
}

+ (void)fbLogOut {
    [[FacebookModule sharedFBLoginManeger] logOut];
}



// Facebook Login (& Sign Up)
+ (void)fbLoginFromVC:(UIViewController *)fromVC
  withCompletionBlock:(void (^)(BOOL isSuccess, NSString *token))completionBlock {
    
    [[self sharedFBLoginManeger] logInWithReadPermissions:@[@"public_profile", @"email", @"user_friends"]
                                       fromViewController:fromVC
                                                  handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                                      
                                                      NSLog(@"%@", [FBSDKAccessToken currentAccessToken]);
                                                      
                                                      if (error) {
                                                          NSLog(@"network error : %@", error.localizedDescription);
                                                          
                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                              completionBlock(NO, nil);
                                                          });
                                                      } else if (result.isCancelled) {
                                                          NSLog(@"isCancelled");
                                                          
                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                              completionBlock(NO, nil);
                                                          });
                                                      } else {
                                                          NSLog(@"Facebook Login Success");
                                                          
                                                          // User Info Data 받아옴
                                                          [self getFacebookProfileInfosWithCompletionBlock:^(MomoUserDataSet *momoUserData) {
                                                              
                                                              [DataCenter sharedInstance].momoUserData = momoUserData;      // set UserData
                                                              
                                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                                  [DataCenter saveMomoUserData];  // DB저장
                                                                  completionBlock(YES, result.token.tokenString);
                                                              });
                                                          }];
                                                      }
                                                  }];
}

// 페북 계정, 서버로부터 유저 프로필 정보들 받아오는 메서드
+ (void)getFacebookProfileInfosWithCompletionBlock:(void (^)(MomoUserDataSet *momoUserData))completionBlock {
    
    MomoUserDataSet *momoUserData = [[MomoUserDataSet alloc] init];
    
//    momoUserData.user_fb_token = [FBSDKAccessToken currentAccessToken];
    momoUserData.user_token = [FBSDKAccessToken currentAccessToken].tokenString;
    momoUserData.user_id = [FBSDKAccessToken currentAccessToken].userID;
    
    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields":@"id, name, picture.type(large), email"}] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {

        NSLog(@"result : %@", result);
        
        if (!error) {
            if ([result objectForKey:@"name"]) {
                momoUserData.user_username = [result objectForKey:@"name"];
                NSLog(@"momoUserData.user_username : %@", momoUserData.user_username);
            }
            if ([result objectForKey:@"picture"]) {
                momoUserData.user_profile_image_url = result[@"picture"][@"data"][@"url"];
                momoUserData.user_profile_image_data = [NSData dataWithContentsOfURL:[NSURL URLWithString:momoUserData.user_profile_image_url]];
                NSLog(@"url : %@", result[@"picture"][@"data"][@"url"]);
            }
            if ([result objectForKey:@"email"]) {
                momoUserData.user_email = [result objectForKey:@"email"];
                NSLog(@"momoUserData.user_email : %@", momoUserData.user_email);
            }

        } else {
            NSLog(@"network error : %@", error.localizedDescription);
        }
        
        [NetworkModule getUserMapDataWithCompletionBlock:^(RLMArray<MomoMapDataSet *><MomoMapDataSet> *user_map_list) {
            momoUserData.user_map_list = user_map_list;
            completionBlock(momoUserData);
        }];
    }];
}


@end
