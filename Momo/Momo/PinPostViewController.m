//
//  PinPostViewController.m
//  Momo
//
//  Created by Hanson Jung on 2017. 4. 13..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import "PinPostViewController.h"
#import "PinContentsCollectionViewCell.h"
#import "PhotoCell.h"
#import "TextCell.h"
#import "PhotoTextCell.h"

@interface PinPostViewController ()
<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;

@property (nonatomic) NSArray *dataTempArr;
@property (nonatomic) NSArray *dataTempArr2;

@end

@implementation PinPostViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.dataTempArr = @[@"Zion", @"Yosemite", @"Sequoia", @"Rocky Mountains", @"Olympic", @"North Cascades", @"Mount Rainier", @"Mesa Verde"];
    
    self.dataTempArr2 = @[
                         @[@0, @"Yosemite", @"동해물과백두산이마르고닳도록동해물과백두산이마르고닳도록동해물과백두산이마르고닳도록동해물과백두산이마르고닳도록동해물과백두산이마르고닳도록"],
                         @[@1, @"Zion"],
                         @[@2, @"여기는 빵이 맛있는 곳gyftfytgytgyuguygyawejflajwlkdjasfl해물과백두산이마르고닳도록동해물과백두산이마르고닳도록동해해물과백두산이마르고닳도록동해물과백두산이마르고닳도록동해"],
                         @[@2, @"여기는 빵이 맛있는 곳gyftfytgytgyuguygyawejflajwlkdjasfl해물과백두산이마르고닳도록동"],
                         @[@2, @"여기"],
                         @[@2, @"여기는 빵이 맛있는 곳gyftfytgytgyuguygyawejflajwlkdjasfl해물과백두산이마르고닳도록동해물과백두산이마르고닳도록동해해물과백두산이마르고닳도록동해물과백두산이마르고닳도록동해여기는 빵이 맛있는 곳gyftfytgytgyuguygyawejflajwlkdjasfl해물과백두산이마르고닳도록동해물과백두산이마르고닳도록동해해물과백두산이마르고닳도록동해물과백두산이마르고닳도록동해여기는 빵이 맛있는 곳gyftfytgytgyuguygyawejflajwlkdjasfl해물과백두산이마르고닳도록동해물과백두산이마르고닳도록동해해물과백두산이마르고닳도록동해물과백두산이마르고닳도록동해여기는 빵이 맛있는 곳gyftfytgytgyuguygyawejflajwlkdjasfl해물과백두산이마르고닳도록동해물과백두산이마르고닳도록동해해물과백두산이마르고닳도록동해물과백두산이마르고닳도록동해여기는 빵이 맛있는 곳gyftfytgytgyuguygyawejflajwlkdjasfl해물과백두산이마르고닳도록동해물과백두산이마르고닳도록동해해물과백두산이마르고닳도록동해물과백두산이마르고닳도록동해여기는 빵이 맛있는 곳gyftfytgytgyuguygyawejflajwlkdjasfl해물과백두산이마르고닳도록동해물과백두산이마르고닳도록동해해물과백두산이마르고닳도록동해물과백두산이마르고닳도록동해여기는 빵이 맛있는 곳gyftfytgytgyuguygyawejflajwlkdjasfl해물과백두산이마르고닳도록동해물과백두산이마르고닳도록동해해물과백두산이마르고닳도록동해물과백두산이마르고닳도록동해"],
                         @[@0, @"Sequoia", @"남산위의저소나무철갑을두른듯"]
                         ];
    
    
    
    
    self.tableView.estimatedRowHeight = 180;    // 글만 있을 때 (제일 작은 사이즈)
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.dataTempArr2.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if ([((NSNumber *)self.dataTempArr2[indexPath.row][0]) integerValue] == 0) {
        // 글 사진 다 있는 경우
        PhotoTextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"photoTextCell" forIndexPath:indexPath];
        cell.profileImageView1.layer.cornerRadius = cell.profileImageView1.frame.size.width/2;
        cell.profileImageView1.layer.masksToBounds = YES;
        cell.profileImageView1.image = [UIImage imageNamed:@"DeadpoolShocked.jpg"];
        cell.categoryColorView1.backgroundColor = [UIColor colorWithRed:45.0f / 255.0f green:204.0f / 255.0f blue:178.0f / 255.0f alpha:1.0f];
        cell.categoryColorView1.layer.cornerRadius = cell.categoryColorView1.frame.size.width/2;
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        //    [cell.contentImageView1 setImage:[UIImage imageNamed:@"Zion"]];
        //    [cell.pinMainText1 setText:@"ajkglkdlkjgalk"];
        [cell.contentImageView1 setImage:[UIImage imageNamed:self.dataTempArr2[indexPath.row][1]]];
        [cell.pinMainText1 setText:self.dataTempArr2[indexPath.row][2]];
        return cell;
    
    } else if ([((NSNumber *)self.dataTempArr2[indexPath.row][0]) integerValue] ==1) {
        // 사진만 있는 경우
        PhotoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"photoCell" forIndexPath:indexPath];
        cell.profileImageView2.layer.cornerRadius = cell.profileImageView2.frame.size.width/2;
        cell.profileImageView2.layer.masksToBounds = YES;
        cell.profileImageView2.image = [UIImage imageNamed:@"DeadpoolShocked.jpg"];
        cell.categoryColorView2.backgroundColor = [UIColor colorWithRed:45.0f / 255.0f green:204.0f / 255.0f blue:178.0f / 255.0f alpha:1.0f];
        cell.categoryColorView2.layer.cornerRadius = cell.categoryColorView2.frame.size.width/2;
//        cell.categoryImg2.image = [UIImage imageNamed:@"04S"];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell.contentImageView2 setImage:[UIImage imageNamed:self.dataTempArr2[indexPath.row][1]]];
        return cell;

    
    } else {
        // 글만 있는 경우
        TextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"textCell" forIndexPath:indexPath];
        //        [cell.contentImageView setHidden:YES];
        cell.profileImageView3.layer.cornerRadius = cell.profileImageView3.frame.size.width/2;
        cell.profileImageView3.layer.masksToBounds = YES;
        cell.profileImageView3.image = [UIImage imageNamed:@"DeadpoolShocked.jpg"];
        cell.categoryColorView3.backgroundColor = [UIColor colorWithRed:45.0f / 255.0f green:204.0f / 255.0f blue:178.0f / 255.0f alpha:1.0f];
        cell.categoryColorView3.layer.cornerRadius = cell.categoryColorView3.frame.size.width/2;
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
       
        [cell.pinMainText3 setText:self.dataTempArr2[indexPath.row][1]];
        return cell;
    }
    
}

// Back Btn Action
- (IBAction)selectedPopViewBtn:(id)sender {
    //Navigation없애고 커스텀 버튼으로 POP
    [self.navigationController popViewControllerAnimated:YES];
    
}

@end


