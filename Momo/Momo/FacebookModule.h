//
//  FacebookModule.h
//  Momo
//
//  Created by Jeheon Choi on 2017. 4. 11..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FBSDKLoginManager;

@interface FacebookModule : NSObject

// Facebook account -------------------------------//
#pragma mark - Facebook Auth Account Methods

+ (void)fbLogOut;

// Facebook Login (& Sign Up)
+ (void)fbLoginFromVC:(UIViewController *)fromVC
  withCompletionBlock:(void (^)(BOOL isSuccess, NSString *token))completionBlock;


+ (void)getFacebookProfileInfosWithCompletionBlock:(void (^)(MomoUserDataSet *momoUserData))completionBlock;

@end
