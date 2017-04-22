//
//  UtilityCenter.m
//  Momo
//
//  Created by Jeheon Choi on 2017. 4. 22..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import "UtilityCenter.h"

@implementation UtilityCenter

+ (void)presentCommonAlertController:(UIViewController *)fromVC
                         withMessage:(NSString *)message {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"oops!"
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"확인"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    [alertController addAction:okButton];
    [fromVC presentViewController:alertController animated:YES completion:nil];
}

@end
