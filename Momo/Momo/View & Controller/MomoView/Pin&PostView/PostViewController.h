//
//  PostViewController.h
//  Momo
//
//  Created by Hanson Jung on 2017. 4. 13..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PostViewController : UIViewController

// 초기 포스트뷰 데이터 세팅
- (void)showSelectedPostAndSetPostData:(MomoPostDataSet *)postData;

@end
