//
//  PinPostViewController.m
//  Momo
//
//  Created by Hanson Jung on 2017. 4. 13..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import "PinPostViewController.h"


@interface PostTableViewCell : UITableViewCell

// constraint
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentImageHeight;

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UIImageView *contentImageView;
@property (weak, nonatomic) IBOutlet UILabel *pinName;
@property (weak, nonatomic) IBOutlet UILabel *pinAddress;
@property (weak, nonatomic) IBOutlet UILabel *pinMainText;

@end


@implementation PostTableViewCell


@end


//////////////////////////////////////////////////////


@interface PinPostViewController ()
<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) NSArray *dataTempArr;
@property (nonatomic) NSArray *dataTempArr2;

@end

@implementation PinPostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
//    self.dataTempArr = @[@"Zion", @"Yosemite", @"Sequoia", @"Rocky Mountains", @"Olympic", @"North Cascades", @"Mount Rainier", @"Mesa Verde"];
    
    self.dataTempArr2 = @[
                         @[@0, @"여기는 빵이 맛있는 곳"],
                         @[@1, @"Zion"],
                         @[@2, @"Yosemite", @"동해물과백두산이마르고닳도록동해물과백두산이마르고닳도록동해물과백두산이마르고닳도록동해물과백두산이마르고닳도록동해물과백두산이마르고닳도록"],
                         ];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    PostTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    [cell.contentImageView setImage:[UIImage imageNamed:self.dataTempArr[indexPath.row]]];
    
    cell.profileImageView.layer.cornerRadius = cell.profileImageView.frame.size.width/2;
    cell.profileImageView.layer.masksToBounds = YES;
    cell.profileImageView.image = [UIImage imageNamed:@"DeadpoolShocked.jpg"];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    if ([((NSNumber *)self.dataTempArr2[0]) integerValue] == 0) {
        // 글만 있는 경우
        
        
    } else if ([((NSNumber *)self.dataTempArr2[0]) integerValue] == 1) {
        // 사진만 있는 경우
        
        
    } else if ([((NSNumber *)self.dataTempArr2[0]) integerValue] == 2) {
        // 글 사진 다 있는 경우
        
        
    }
    
//    [cell.contentImageView setImage:[UIImage imageNamed:self.dataTempArr];
    
    return cell;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.dataTempArr.count;
}

@end


