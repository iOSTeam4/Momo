//
//  UserProfileHeaderView.h
//  Momo
//
//  Created by Jeheon Choi on 2017. 4. 6..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UserProfileHeaderBtnSelectDelegate;


@interface UserProfileHeaderView : UITableViewHeaderFooterView

@property (weak, nonatomic) id<UserProfileHeaderBtnSelectDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIView *backView;

@property (weak, nonatomic) IBOutlet UIImageView *userImgView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userIDLabel;

@property (weak, nonatomic) IBOutlet UIButton *userEditBtn;

@property (weak, nonatomic) IBOutlet UILabel *userCommentLabel;

@property (weak, nonatomic) IBOutlet UIButton *mapBtn;
@property (weak, nonatomic) IBOutlet UIButton *pinBtn;

@end




// 지도, 핀 버튼 델리게이트 프로토콜 -----------------------//

@protocol UserProfileHeaderBtnSelectDelegate <NSObject>

- (void)selectedMapPinBtnWithNum:(NSInteger)num;

@end
