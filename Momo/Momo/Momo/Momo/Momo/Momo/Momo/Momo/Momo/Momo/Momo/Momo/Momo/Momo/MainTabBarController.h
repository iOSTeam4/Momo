//
//  MainTabBarController.h
//  Momo
//
//  Created by Jeheon Choi on 2017. 3. 27..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainTabBarController : UITabBarController

- (void)customTabBarSetHidden:(BOOL)hidden;

// MakeViewController 버튼들의 Selector Methods (직접 불러 사용하지 않음)
- (void)selectedMakeMapBtn:(UIButton *)sender;
- (void)selectedMakePinBtn:(UIButton *)sender;

@end
