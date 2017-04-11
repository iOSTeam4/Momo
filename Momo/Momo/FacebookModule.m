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
                                                                  completionBlock(YES, result.token.tokenString);
                                                              });
                                                          }];
                                                      }
                                                  }];
}


+ (void)getFacebookProfileInfosWithCompletionBlock:(void (^)(MomoUserDataSet *momoUserData))completionBlock {
    
    MomoUserDataSet *momoUserData = [[MomoUserDataSet alloc] init];
    
//    momoUserData.user_fb_token = [FBSDKAccessToken currentAccessToken];
    momoUserData.user_token = [FBSDKAccessToken currentAccessToken].tokenString;
    momoUserData.user_id = [FBSDKAccessToken currentAccessToken].userID;
    
    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields":@"id, name, email, picture.width(100).height(100)"}] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {

        NSLog(@"result : %@", result);
        
        if (!error) {
            if ([result objectForKey:@"name"]) {
                momoUserData.user_username = [result objectForKey:@"name"];
                NSLog(@"momoUserData.user_username : %@", momoUserData.user_username);
            }
            if ([result objectForKey:@"email"]) {
                momoUserData.user_email = [result objectForKey:@"email"];
                NSLog(@"momoUserData.user_email : %@", momoUserData.user_email);
            }
            if ([result objectForKey:@"picture"]) {
                momoUserData.user_profile_image = [result objectForKey:@"picture"];
                NSLog(@"momoUserData.user_profile_image : %@", momoUserData.user_profile_image);
            }
        } else {
            NSLog(@"network error : %@", error.localizedDescription);
        }
        
        completionBlock(momoUserData);
    }];
}


@end
