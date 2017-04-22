//
//  UtilityCenter.h
//  Momo
//
//  Created by Jeheon Choi on 2017. 4. 22..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UtilityCenter : NSObject

+ (void)presentCommonAlertController:(UIViewController *)fromVC
                         withMessage:(NSString *)message;

@end
