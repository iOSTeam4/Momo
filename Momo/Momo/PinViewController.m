//
//  PinViewController.m
//  Momo
//
//  Created by Jeheon Choi on 2017. 3. 28..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import "PinViewController.h"
#import "PinContentsCollectionViewCell.h"

@interface PinViewController ()
<UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;
@property (weak, nonatomic) IBOutlet UIView *mapPreView;

@property (weak, nonatomic) IBOutlet UILabel *pinName;
@property (weak, nonatomic) IBOutlet UILabel *pinAddress;
@property (weak, nonatomic) IBOutlet UILabel *pinMainText;

@property (nonatomic) NSArray *dataTempArr;

@end

@implementation PinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGFloat itemWidth = self.collectionView.frame.size.width / 2.0f;
    self.flowLayout.itemSize = CGSizeMake(itemWidth, itemWidth);
    
    
    
    self.dataTempArr = @[@"Arches", @"Katmai", @"Denali"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.dataTempArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PinContentsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    [cell.imgView setImage:[UIImage imageNamed:self.dataTempArr[indexPath.row]]];
    
    return cell;
}

//- (void)inputImageData:(NSString *)data {
//    
//    self.contentImageView.image = [UIImage imageNamed:@"Katmai"];
//    
//}


@end
