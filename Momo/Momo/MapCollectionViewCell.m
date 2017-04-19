//
//  MapCollectionViewCell.m
//  Momo
//
//  Created by Hanson Jung on 2017. 4. 19..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import "MapCollectionViewCell.h"

@implementation MapCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    NSLog(@"MapCollectionViewCell awakeFromNib");
 
    
    [self initialSetting];
    
}


- (void)layoutSubviews {
    [super layoutSubviews];
    NSLog(@"MapCollectionViewCell layoutSubviews");
    
}


- (void)initialSetting {
    
}


@end
