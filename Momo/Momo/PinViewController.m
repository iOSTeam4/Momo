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
<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout      >

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;
@property (weak, nonatomic) IBOutlet UIView *mapPreView;

@property (weak, nonatomic) IBOutlet UILabel *pinName;
@property (weak, nonatomic) IBOutlet UILabel *pinAddress;
@property (weak, nonatomic) IBOutlet UILabel *pinMainText;
@property (weak, nonatomic) IBOutlet UIImageView *userProfileImage;
@property (weak, nonatomic) IBOutlet UILabel *userNameToMade;
@property (weak, nonatomic) IBOutlet UILabel *date;

@property (nonatomic) NSArray *dataTempArr;

@end

@implementation PinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //collectionView size
    CGFloat itemWidth = self.collectionView.frame.size.width / 3.0f;
    self.flowLayout.itemSize = CGSizeMake(itemWidth, itemWidth);
    // collectionView 임시 contents
    self.dataTempArr = @[@"addPost", @"textPhoto", @"postTest1", @"postTest2", @"postTest3", @"postTest4", @"postTest5", @"postTest6"];
    
    // pin 생성user
    self.userProfileImage.layer.cornerRadius = self.userProfileImage.frame.size.width/2;
    self.userProfileImage.layer.masksToBounds = YES;
    self.userProfileImage.image = [UIImage imageNamed:@"DeadpoolShocked.jpg"];

}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [GoogleAnalyticsModule startGoogleAnalyticsTrackingWithScreenName:@"PinViewController"];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.dataTempArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    PinContentsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    [cell.contentsBtn setImage:[UIImage imageNamed:self.dataTempArr[indexPath.row]] forState:UIControlStateNormal];
    [cell.contentsBtn setTag:indexPath.row];
    
    return cell;
}

- (IBAction)selectedContentsBtnAction:(UIButton *)sender {
    
    NSLog(@"버튼 눌림 tag = %ld", sender.tag);
    
    if (sender.tag == 0) {
//        PinModificationViewController *pinModiVC = [[PinModificationViewController alloc] init];
        
//        PinModificationViewController *pinModiVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PinModificationViewController"];
//        [self.navigationController pushViewController:pinModiVC animated:YES];
        
        [self performSegueWithIdentifier:@"pinModiSegue" sender:self];
        
    } else {
        
        [self performSegueWithIdentifier:@"pinDetailSegue" sender:self];
    }
}


//- (void)inputImageData:(NSString *)data {
//    
//    self.contentImageView.image = [UIImage imageNamed:@"Katmai"];
//    
//}


@end
