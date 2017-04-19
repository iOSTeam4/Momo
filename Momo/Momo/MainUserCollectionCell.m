//
//  MainUserCollectionCell.m
//  Momo
//
//  Created by Hanson Jung on 2017. 4. 19..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import "MainUserCollectionCell.h"

@implementation MainUserCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.titleLabel.textColor = [UIColor blackColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
