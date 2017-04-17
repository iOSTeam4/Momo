//
//  FollowViewController.h
//  Momo
//
//  Created by Jeheon Choi on 2017. 4. 17..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - FollowTableViewCell
// FollowTableViewCell -----------------------------//

@interface FollowTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *backView;

@property (weak, nonatomic) IBOutlet UIImageView *userImgView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userIDLabel;

@property (weak, nonatomic) IBOutlet UIButton *followBtn;

@end



#pragma mark - FollowViewController
// FollowViewController ----------------------------//

@interface FollowViewController : UIViewController

@end
