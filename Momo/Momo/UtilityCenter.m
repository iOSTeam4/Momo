//
//  UtilityCenter.m
//  Momo
//
//  Created by Jeheon Choi on 2017. 4. 22..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import "UtilityCenter.h"

@implementation UtilityCenter

// 일반 얼럿 뷰컨트롤러
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


// 이미지 리사이징 데이터
+ (NSData *)imgResizing:(UIImage *)img {

    if (img) {  // not nil
        // 이미지 데이터 압축, 허용 용량 약 2.5mb정도
        // Point가 아닌, Pixel 사이즈로 조정됨 : 약 25kb img
        CGSize imgSize = CGSizeMake(500.0f, 500.0f);
        
        UIGraphicsBeginImageContext(imgSize);
        [img drawInRect:CGRectMake(0,0,imgSize.width,imgSize.height)];
        UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return UIImageJPEGRepresentation(resizedImage, 1);
    } else {
        return nil;
    }
}

@end
