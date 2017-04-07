//
//  PinProfileTableViewCell.m
//  Momo
//
//  Created by Jeheon Choi on 2017. 4. 6..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import "PinProfileTableViewCell.h"

@implementation PinProfileTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)layoutSubviews {
    [super layoutSubviews];
    NSLog(@"layoutSubviews");
    
    // 프로필 BackView 세팅
    [self.backView.layer setCornerRadius:20];
    
    // 프로필 사진 동그랗게
    [self.userImgView.layer setCornerRadius:self.userImgView.frame.size.height/2];
    
    // 수정하기 버튼
    [self.pinEditBtn.layer setCornerRadius:5];
    [self.pinEditBtn.layer setBorderColor:[UIColor mm_brightSkyBlueColor].CGColor];
    [self.pinEditBtn.layer setBorderWidth:1];
    
    // 전체 Cell Frame 설정
    self.backView.frame = CGRectMake(self.backView.frame.origin.x, self.backView.frame.origin.y, self.backView.frame.size.width, self.pinEditBtn.frame.origin.y + self.pinEditBtn.frame.size.height + 10);
    
}

@end
