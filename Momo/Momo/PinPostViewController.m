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

@property (nonatomic) MomoPostDataSet *postData;
@property (nonatomic) MomoPinDataSet *pinData;
@property (nonatomic) NSInteger selectedPostIndex;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation PinPostViewController

// 초기 포스트뷰 데이터 세팅
- (void)showSelectedPostAndSetPostData:(MomoPostDataSet *)postData {
    self.postData = postData;
    self.pinData = [MomoPinDataSet objectsWhere:[NSString stringWithFormat:@"pk==%ld", postData.post_pin_pk]][0];  // post가 속한 pin
    self.selectedPostIndex = [self.pinData.pin_post_list indexOfObject:postData];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // TableView Settings -----------------//
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLineEtched];
    
    // cell automatic Dimension
    self.tableView.estimatedRowHeight = 180;    // 글만 있을 때 (제일 작은 사이즈)
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    // 선택한 포스트로 바로 이동
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedPostIndex inSection:0]
                          atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.pinData.pin_post_list.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self.pinData.pin_post_list[indexPath.row].post_description length] && [self.pinData.pin_post_list[indexPath.row].post_photo_data length]) {
        // 글 사진 다 있는 경우
        PhotoTextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"photoTextCell" forIndexPath:indexPath];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        cell.profileImageView1.layer.cornerRadius = cell.profileImageView1.frame.size.width/2;
        cell.profileImageView1.layer.masksToBounds = YES;
        cell.profileImageView1.image = [self.pinData.pin_post_list[indexPath.row].post_author getAuthorProfileImg];
        
        cell.categoryImg1.image = [self.pinData labelIcon];
        
        [cell.contentImageView1 setImage:[self.pinData.pin_post_list[indexPath.row] getPostPhoto]];     // 사진
        [cell.pinMainText1 setText:self.pinData.pin_post_list[indexPath.row].post_description];         // 글
        
        return cell;
    
    } else if ([self.pinData.pin_post_list[indexPath.row].post_photo_data length]) {
        // 사진만 있는 경우
        PhotoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"photoCell" forIndexPath:indexPath];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        cell.profileImageView2.layer.cornerRadius = cell.profileImageView2.frame.size.width/2;
        cell.profileImageView2.layer.masksToBounds = YES;
        cell.profileImageView2.image = [self.pinData.pin_post_list[indexPath.row].post_author getAuthorProfileImg];
        
        cell.categoryImg2.image = [self.pinData labelIcon];
        
        [cell.contentImageView2 setImage:[self.pinData.pin_post_list[indexPath.row] getPostPhoto]];     // 사진

        return cell;

    } else {
        // 글만 있는 경우
        TextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"textCell" forIndexPath:indexPath];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        cell.profileImageView3.layer.cornerRadius = cell.profileImageView3.frame.size.width/2;
        cell.profileImageView3.layer.masksToBounds = YES;
        cell.profileImageView3.image = [self.pinData.pin_post_list[indexPath.row].post_author getAuthorProfileImg];

        cell.categoryImg3.image = [self.pinData labelIcon];
       
        [cell.pinMainText3 setText:self.pinData.pin_post_list[indexPath.row].post_description];         // 글

        return cell;
    }
}


@end


