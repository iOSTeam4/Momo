//
//  PhotoCell.h
//  Momo
//
//  Created by Hanson Jung on 2017. 4. 17..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoCell : UITableViewCell

// constraint

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView2;
@property (weak, nonatomic) IBOutlet UIView *categoryColorView2;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel2;
@property (weak, nonatomic) IBOutlet UIButton *editBtn2;
@property (weak, nonatomic) IBOutlet UILabel *userName2;
@property (weak, nonatomic) IBOutlet UIImageView *contentImageView2;
@property (weak, nonatomic) IBOutlet UILabel *pinName2;
@property (weak, nonatomic) IBOutlet UILabel *pinAddress2;

@end
