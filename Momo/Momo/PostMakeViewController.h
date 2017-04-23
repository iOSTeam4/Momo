//
//  PostMakeViewController.h
//  Momo
//
//  Created by Hanson Jung on 2017. 4. 7..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PostMakeViewController : UIViewController

// 생성할 때, 미리 부르는 메서드
- (void)setMakeModeWithPinPK:(NSInteger)pin_pk;

// 수정할 때, 미리 부르는 메서드
- (void)setEditModeWithPostData:(MomoPostDataSet *)postData;

@end
