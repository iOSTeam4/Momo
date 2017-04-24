//
//  TextCell.m
//  Momo
//
//  Created by Hanson Jung on 2017. 4. 17..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import "TextCell.h"

@interface TextCell ()


@end

@implementation TextCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)editBtnAction:(id)sender {

    [self.delegate editBtnAction:self.tag];

}

@end
