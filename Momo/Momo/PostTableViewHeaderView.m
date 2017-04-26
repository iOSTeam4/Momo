//
//  PostTableViewHeaderView.m
//  Momo
//
//  Created by Jeheon Choi on 2017. 4. 26..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import "PostTableViewHeaderView.h"

@implementation PostTableViewHeaderView


- (void)awakeFromNib {
    [super awakeFromNib];
}


- (void)layoutSubviews {
    [super layoutSubviews];
}


- (IBAction)backBtnAction:(id)sender {

    [self.delegate backBtnAction];
}

- (IBAction)addPostBtnAction:(id)sender {

    [self.delegate addPostBtnAction];
}

@end
