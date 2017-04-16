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

// Facebook Log out
+ (void)fbLogOut;

// Facebook Login (& Sign Up)
+ (void)fbLoginFromVC:(UIViewController *)fromVC
  withCompletionBlock:(void (^)(BOOL isSuccess, NSString *result))completionBlock;


@end
