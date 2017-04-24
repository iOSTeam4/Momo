//
//  PhotoTextCell.h
//  Momo
//
//  Created by Hanson Jung on 2017. 4. 17..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoTextCell : UITableViewCell

// constraint

@property (weak, nonatomic) IBOutlet UILabel *categoryLabel1;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView1;
@property (weak, nonatomic) IBOutlet UIView *categoryColorView1;
@property (weak, nonatomic) IBOutlet UILabel *userName1;
@property (weak, nonatomic) IBOutlet UIButton *editBtn1;
@property (weak, nonatomic) IBOutlet UIImageView *contentImageView1;
@property (weak, nonatomic) IBOutlet UILabel *pinName1;
@property (weak, nonatomic) IBOutlet UILabel *pinAddress1;
@property (weak, nonatomic) IBOutlet UILabel *pinMainText1;

@end
