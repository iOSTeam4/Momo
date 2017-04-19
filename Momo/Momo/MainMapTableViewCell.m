//
//  MainMapTableViewCell.m
//  Momo
//
//  Created by Hanson Jung on 2017. 4. 19..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import "MainMapTableViewCell.h"

#import "MapCollectionViewCell.h"

@interface MainMapTableViewCell () <UICollectionViewDataSource>

@end

@implementation MainMapTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    NSLog(@"MainMapTableViewCell awakeFromNib");
    // Initialization code
    
    [self initialSetting];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    NSLog(@"MainMapTableViewCell layoutSubviews");
    
}




- (void)initialSetting {
    // Nib Resister
    UINib *mapCellNib = [UINib nibWithNibName:@"MapCollectionViewCell" bundle:nil];
    [self.collectionView registerNib:mapCellNib forCellWithReuseIdentifier:@"mapCollectionViewCell"];
    
    self.collectionView.dataSource = self;
//    [self.collectionView setBackgroundColor:[UIColor purpleColor]];

}


// UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 15;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"cellForItemAtIndexPath");
    
    // Cell Create or Dequeue
    MapCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"mapCollectionViewCell" forIndexPath:indexPath];
        
    return cell;
}



@end
