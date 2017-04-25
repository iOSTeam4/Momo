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
#import "PostMakeViewController.h"

#import "PostMakeViewController.h"

@interface PinPostViewController ()
<UITableViewDataSource, UITableViewDelegate, PhotoTextCellDelegate, TextCellDelegate, PhotoCellDelegate>

@property (nonatomic) MomoPostDataSet *postData;
@property (nonatomic) MomoPinDataSet *pinData;
@property (nonatomic) NSInteger selectedPostIndex;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;

@end

@implementation PinPostViewController

// 초기 포스트뷰 데이터 세팅
- (void)showSelectedPostAndSetPostData:(MomoPostDataSet *)postData {
    self.postData = postData;
    self.pinData = [DataCenter findPinDataWithPinPK:postData.post_pin_pk];          // post가 속한 pin
    self.selectedPostIndex = [self.pinData.pin_post_list indexOfObject:postData];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // TableView Settings -----------------//

    // cell automatic Dimension
    self.tableView.estimatedRowHeight = 180;    // 글만 있을 때 (제일 작은 사이즈)
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    // 선택한 포스트로 바로 이동
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.pinData.pin_post_list.count - self.selectedPostIndex - 1 inSection:0]
                          atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 반드시 테이블 뷰 refresh 해야함
    [self.tableView reloadData];
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.25f;   // Plain style일 때, Separator Line 계속 생기지 않게 하는 방법
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.pinData.pin_post_list.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self.pinData.pin_post_list[self.pinData.pin_post_list.count - indexPath.row - 1].post_description length] && [self.pinData.pin_post_list[self.pinData.pin_post_list.count - indexPath.row - 1].post_photo_data length]) {
        // 글 사진 다 있는 경우
        PhotoTextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"photoTextCell" forIndexPath:indexPath];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.tag = indexPath.row;
        cell.delegate = self;
        
        // 핀 이름, 주소
        cell.pinName1.text = self.pinData.pin_name;
        cell.pinAddress1.text = self.pinData.pin_place.place_address;
        
        // 핀 작성자 username, img
        cell.userName1.text = self.pinData.pin_post_list[self.pinData.pin_post_list.count - indexPath.row - 1].post_author.username;
        cell.profileImageView1.image = [self.pinData.pin_post_list[self.pinData.pin_post_list.count - indexPath.row - 1].post_author getAuthorProfileImg];
        cell.profileImageView1.image = [self.pinData.pin_post_list[self.pinData.pin_post_list.count - indexPath.row - 1].post_author getAuthorProfileImg];
        cell.profileImageView1.layer.cornerRadius = cell.profileImageView1.frame.size.width/2;
        cell.profileImageView1.layer.masksToBounds = YES;

        // 핀 카테고리 라벨
        cell.categoryLabel1.text = [self categoryLabelText];
        cell.categoryColorView1.backgroundColor = [self.pinData labelColor];
        cell.categoryColorView1.layer.cornerRadius = cell.categoryColorView1.frame.size.width/2;
        
        // * 사진 & 글 *
        [cell.contentImageView1 setImage:[self.pinData.pin_post_list[self.pinData.pin_post_list.count - indexPath.row - 1] getPostPhoto]];     // 사진
        [cell.pinMainText1 setText:self.pinData.pin_post_list[self.pinData.pin_post_list.count - indexPath.row - 1].post_description];         // 글
        
        return cell;
    
    } else if ([self.pinData.pin_post_list[self.pinData.pin_post_list.count - indexPath.row - 1].post_photo_data length]) {
        // 사진만 있는 경우
        PhotoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"photoCell" forIndexPath:indexPath];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.tag = indexPath.row;
        cell.delegate = self;
        
        // 핀 이름, 주소
        cell.pinName2.text = self.pinData.pin_name;
        cell.pinAddress2.text = self.pinData.pin_place.place_address;
        
        // 핀 작성자 username, img
        cell.userName2.text = self.pinData.pin_post_list[self.pinData.pin_post_list.count - indexPath.row - 1].post_author.username;
        cell.profileImageView2.image = [self.pinData.pin_post_list[self.pinData.pin_post_list.count - indexPath.row - 1].post_author getAuthorProfileImg];
        cell.profileImageView2.image = [self.pinData.pin_post_list[self.pinData.pin_post_list.count - indexPath.row - 1].post_author getAuthorProfileImg];
        cell.profileImageView2.layer.cornerRadius = cell.profileImageView2.frame.size.width/2;
        cell.profileImageView2.layer.masksToBounds = YES;

        // 핀 카테고리 라벨
        cell.categoryLabel2.text = [self categoryLabelText];
        cell.categoryColorView2.backgroundColor = [self.pinData labelColor];
        cell.categoryColorView2.layer.cornerRadius = cell.categoryColorView2.frame.size.width/2;
        
        // * 사진 *
        [cell.contentImageView2 setImage:[self.pinData.pin_post_list[self.pinData.pin_post_list.count - indexPath.row - 1] getPostPhoto]];

        return cell;

    } else {
        // 글만 있는 경우
        TextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"textCell" forIndexPath:indexPath];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.tag = indexPath.row;
        cell.delegate = self;
        
        // 핀 이름, 주소
        cell.pinName3.text = self.pinData.pin_name;
        cell.pinAddress3.text = self.pinData.pin_place.place_address;
        
        // 핀 작성자 username, img
        cell.userName3.text = self.pinData.pin_post_list[self.pinData.pin_post_list.count - indexPath.row - 1].post_author.username;
        cell.profileImageView3.image = [self.pinData.pin_post_list[self.pinData.pin_post_list.count - indexPath.row - 1].post_author getAuthorProfileImg];
        cell.profileImageView3.image = [self.pinData.pin_post_list[self.pinData.pin_post_list.count - indexPath.row - 1].post_author getAuthorProfileImg];
        cell.profileImageView3.layer.cornerRadius = cell.profileImageView3.frame.size.width/2;
        cell.profileImageView3.layer.masksToBounds = YES;

        // 핀 카테고리 라벨
        cell.categoryLabel3.text = [self categoryLabelText];
        cell.categoryColorView3.backgroundColor = [self.pinData labelColor];
        cell.categoryColorView3.layer.cornerRadius = cell.categoryColorView3.frame.size.width/2;
        
        // * 글 *
        [cell.pinMainText3 setText:self.pinData.pin_post_list[self.pinData.pin_post_list.count - indexPath.row - 1].post_description];

        return cell;
    }
}

- (IBAction)addPostBtnAction:(UIButton *)sender {
    NSLog(@"addPostBtnAction");
    
    // Make Post
    PostMakeViewController *postMakeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PostMakeViewController"];
    [postMakeVC setMakeModeWithPinPK:self.pinData.pk];      // pin_pk 전달해줘야 포스트 생성가능
    postMakeVC.wasPostView = YES;    // post뷰에서 이동
    [self presentViewController:postMakeVC animated:YES completion:nil];
    
}


// 카테고리 라벨 Text 메서드
- (NSString *)categoryLabelText {
    
    switch (self.pinData.pin_label) {
        case 0:
            return @"카페";
        case 1:
            return @"음식";
        case 2:
            return @"쇼핑";
        case 3:
            return @"장소";
        default:    // 4
            return @"기타";
    }
}



// Btn Action ------------------------------//

// Back Btn Action
- (IBAction)selectedPopViewBtn:(id)sender {
    // Pop
    [self.navigationController popViewControllerAnimated:YES];
    
}


// Edit Btn Action
- (void)editBtnAction:(NSInteger)index {
    NSLog(@"editBtnAction");
    
    // 포스트 수정
    PostMakeViewController *postMakeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PostMakeViewController"];
    
    [postMakeVC setEditModeWithPostData:self.pinData.pin_post_list[self.pinData.pin_post_list.count - index - 1]];   // 수정 모드, 데이터 세팅
    postMakeVC.wasPostView = YES;    // post뷰에서 이동
    
    [self presentViewController:postMakeVC animated:YES completion:nil];
    
}



@end


