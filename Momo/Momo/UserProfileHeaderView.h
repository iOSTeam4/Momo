//
//  UserProfileHeaderView.h
//  Momo
//
//  Created by Jeheon Choi on 2017. 4. 6..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UserProfileHeaderViewDelegate;


@interface UserProfileHeaderView : UITableViewHeaderFooterView

@property (weak, nonatomic) id<UserProfileHeaderViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIView *backView;

@property (weak, nonatomic) IBOutlet UIImageView *userImgView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userIDLabel;

@property (weak, nonatomic) IBOutlet UIButton *userEditBtn;

@property (weak, nonatomic) IBOutlet UILabel *followerLabel;
@property (weak, nonatomic) IBOutlet UIButton *followerBtn;

@property (weak, nonatomic) IBOutlet UILabel *followingLabel;
@property (weak, nonatomic) IBOutlet UIButton *followingBtn;

@property (weak, nonatomic) IBOutlet UILabel *userCommentLabel;

@property (weak, nonatomic) IBOutlet UIButton *mapBtn;
@property (weak, nonatomic) IBOutlet UIButton *pinBtn;
@property (weak, nonatomic) IBOutlet UIButton *mapBtnTap;
@property (weak, nonatomic) IBOutlet UIButton *pinBtnTap;

@end




// 델리게이트 프로토콜 ----------------------------//

@protocol UserProfileHeaderViewDelegate <NSObject>

- (void)selectedFollowerBtn;
- (void)selectedFollowingBtn;
- (void)selectedUserEditBtn;
- (void)selectedMapPinBtnWithNum:(NSInteger)num;    // 지도, 핀 버튼 선택 델리게이트 메서드

@end
