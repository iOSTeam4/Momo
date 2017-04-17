//
//  PinPostViewController.h
//  Momo
//
//  Created by Hanson Jung on 2017. 4. 13..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PostTableViewCell1 : UITableViewCell

// constraint

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView1;
@property (weak, nonatomic) IBOutlet UILabel *userName1;
@property (weak, nonatomic) IBOutlet UIImageView *contentImageView1;
@property (weak, nonatomic) IBOutlet UILabel *pinName1;
@property (weak, nonatomic) IBOutlet UILabel *pinAddress1;
@property (weak, nonatomic) IBOutlet UILabel *pinMainText1;

+ (void)test;

@end

@interface PostTableViewCell2 : UITableViewCell

// constraint

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView2;
@property (weak, nonatomic) IBOutlet UILabel *userName2;
@property (weak, nonatomic) IBOutlet UIImageView *contentImageView2;
@property (weak, nonatomic) IBOutlet UILabel *pinName2;
@property (weak, nonatomic) IBOutlet UILabel *pinAddress2;
+ (void)test;
@end


@interface PostTableViewCell3 : UITableViewCell

// constraint

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView3;
@property (weak, nonatomic) IBOutlet UILabel *userName3;
@property (weak, nonatomic) IBOutlet UILabel *pinName3;
@property (weak, nonatomic) IBOutlet UILabel *pinAddress3;
@property (weak, nonatomic) IBOutlet UILabel *pinMainText3;
+ (void)test;
@end


@interface PinPostViewController : UIViewController

@end
