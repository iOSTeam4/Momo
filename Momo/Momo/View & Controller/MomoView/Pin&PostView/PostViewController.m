//
//  PostViewController.m
//  Momo
//
//  Created by Hanson Jung on 2017. 4. 13..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import "PostViewController.h"

#import "PostTableViewHeaderView.h"
#import "PhotoCell.h"
#import "TextCell.h"
#import "PhotoTextCell.h"

#import "PostMakeViewController.h"

@interface PostViewController ()
<UITableViewDataSource, UITableViewDelegate, PostTableViewHeaderViewDelegate, PhotoTextCellDelegate, TextCellDelegate, PhotoCellDelegate, UIGestureRecognizerDelegate>

@property (nonatomic) MomoPostDataSet *postData;
@property (nonatomic) MomoPinDataSet *pinData;
@property (nonatomic) NSInteger selectedPostIndex;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;

@end

@implementation PostViewController

// 초기 포스트뷰 데이터 세팅
- (void)showSelectedPostAndSetPostData:(MomoPostDataSet *)postData {
    self.postData = postData;
    self.pinData = [DataCenter findPinDataWithPinPK:postData.post_pin_pk];          // post가 속한 pin
    self.selectedPostIndex = [self.pinData.pin_post_list indexOfObject:postData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Navi Pop Gesture 활성화, MapView지나고 나면 popGesture 안되던 현상 처리
    [self.navigationController.interactivePopGestureRecognizer setDelegate:nil];


    // TableView Settings -----------------//
    
    // headerView Nib register & automatic Dimension
    UINib *postTableViewHeaderNib = [UINib nibWithNibName:@"PostTableViewHeaderView" bundle:nil];
    [self.tableView registerNib:postTableViewHeaderNib forHeaderFooterViewReuseIdentifier:@"PostTableViewHeaderView"];
    
    self.tableView.estimatedSectionHeaderHeight = 54;
    self.tableView.sectionHeaderHeight = UITableViewAutomaticDimension;
    
    // cell automatic Dimension
    self.tableView.estimatedRowHeight = 180;    // 글만 있을 때 (제일 작은 사이즈)
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [GoogleAnalyticsModule startGoogleAnalyticsTrackingWithScreenName:@"PinPostViewController"];
    
    // 데이터 변경되었을 때, 바로 반영되어야하므로 viewWillAppear할 때마다 테이블 뷰 refresh
    [self.tableView reloadData];
    
    // 선택 포스트로 바로 이동
    [self.tableView setHidden:YES];     // Post가 많을 때, 최신 게시글의 잔상이 남아, 이동 전까지 hidden 처리함
    // Auto Sizing Cell일 때, Height가 확정되지 않은 시점에서 scrollToRowAtIndexPath 메서드부르면 작동안됨
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedPostIndex inSection:0]
                              atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
        NSLog(@"self.selectedPostIndex : %ld", self.selectedPostIndex);
        [self.tableView setHidden:NO];
        self.selectedPostIndex = 0;     // 초기화
    });
}




// TableView DataSource Delegate Methods -----------------//

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    PostTableViewHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"PostTableViewHeaderView"];
    headerView.delegate = self;
    
    return headerView;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.25f;   // Plain style일 때, Separator Line 계속 생기지 않게 하는 방법
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.pinData.pin_post_list.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self.pinData.pin_post_list[indexPath.row].post_description length] && [self.pinData.pin_post_list[indexPath.row].post_photo_data length]) {
        // 글 사진 다 있는 경우
        PhotoTextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"photoTextCell" forIndexPath:indexPath];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.tag = indexPath.row;
        cell.delegate = self;
        
        // 핀 이름, 주소
        cell.pinName1.text = self.pinData.pin_name;
        cell.pinAddress1.text = self.pinData.pin_place.place_address;
        
        // 핀 작성자 username, img
        cell.userName1.text = self.pinData.pin_post_list[indexPath.row].post_author.username;
        if (self.pinData.pin_post_list[indexPath.row].post_author.profile_img_data) {
            cell.profileImageView1.image = [self.pinData.pin_post_list[indexPath.row].post_author getAuthorProfileImg];
        }
        cell.profileImageView1.layer.cornerRadius = cell.profileImageView1.frame.size.width/2;
        cell.profileImageView1.layer.masksToBounds = YES;

        // 날짜
        NSString *year = [self.postData.post_created_date substringWithRange:NSMakeRange(0, 4)];
        NSString *month = [self.postData.post_created_date substringWithRange:NSMakeRange(5, 2)];
        NSString *day = [self.postData.post_created_date substringWithRange:NSMakeRange(8, 2)];
        cell.postDate1.text = [NSString stringWithFormat:@"%@. %@. %@", year, month, day];
        
        // 핀 카테고리 라벨
        cell.categoryLabel1.text = [self categoryLabelText];
        cell.categoryColorView1.backgroundColor = [self.pinData labelColor];
        cell.categoryColorView1.layer.cornerRadius = cell.categoryColorView1.frame.size.width/2;
        
        // * 사진 & 글 *
        [cell.contentImageView1 setImage:[self.pinData.pin_post_list[indexPath.row] getPostPhoto]];     // 사진
        [cell.pinMainText1 setText:self.pinData.pin_post_list[indexPath.row].post_description];         // 글
        
        return cell;
    
    } else if ([self.pinData.pin_post_list[indexPath.row].post_photo_data length]) {
        // 사진만 있는 경우
        PhotoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"photoCell" forIndexPath:indexPath];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.tag = indexPath.row;
        cell.delegate = self;
        
        // 핀 이름, 주소
        cell.pinName2.text = self.pinData.pin_name;
        cell.pinAddress2.text = self.pinData.pin_place.place_address;
        
        // 핀 작성자 username, img
        cell.userName2.text = self.pinData.pin_post_list[indexPath.row].post_author.username;
        if (self.pinData.pin_post_list[indexPath.row].post_author.profile_img_data) {
            cell.profileImageView2.image = [self.pinData.pin_post_list[indexPath.row].post_author getAuthorProfileImg];
        }
        cell.profileImageView2.layer.cornerRadius = cell.profileImageView2.frame.size.width/2;
        cell.profileImageView2.layer.masksToBounds = YES;
        
        // 날짜
        NSString *year = [self.postData.post_created_date substringWithRange:NSMakeRange(0, 4)];
        NSString *month = [self.postData.post_created_date substringWithRange:NSMakeRange(5, 2)];
        NSString *day = [self.postData.post_created_date substringWithRange:NSMakeRange(8, 2)];
        cell.postDate2.text = [NSString stringWithFormat:@"%@. %@. %@", year, month, day];

        // 핀 카테고리 라벨
        cell.categoryLabel2.text = [self categoryLabelText];
        cell.categoryColorView2.backgroundColor = [self.pinData labelColor];
        cell.categoryColorView2.layer.cornerRadius = cell.categoryColorView2.frame.size.width/2;
        
        // * 사진 *
        [cell.contentImageView2 setImage:[self.pinData.pin_post_list[indexPath.row] getPostPhoto]];

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
        cell.userName3.text = self.pinData.pin_post_list[indexPath.row].post_author.username;
        if (self.pinData.pin_post_list[indexPath.row].post_author.profile_img_data) {
            cell.profileImageView3.image = [self.pinData.pin_post_list[indexPath.row].post_author getAuthorProfileImg];
        }
        cell.profileImageView3.layer.cornerRadius = cell.profileImageView3.frame.size.width/2;
        cell.profileImageView3.layer.masksToBounds = YES;
        
        // 날짜
        NSString *year = [self.postData.post_created_date substringWithRange:NSMakeRange(0, 4)];
        NSString *month = [self.postData.post_created_date substringWithRange:NSMakeRange(5, 2)];
        NSString *day = [self.postData.post_created_date substringWithRange:NSMakeRange(8, 2)];
        cell.postDate3.text = [NSString stringWithFormat:@"%@. %@. %@", year, month, day];

        // 핀 카테고리 라벨
        cell.categoryLabel3.text = [self categoryLabelText];
        cell.categoryColorView3.backgroundColor = [self.pinData labelColor];
        cell.categoryColorView3.layer.cornerRadius = cell.categoryColorView3.frame.size.width/2;
        
        // * 글 *
        [cell.pinMainText3 setText:self.pinData.pin_post_list[indexPath.row].post_description];

        return cell;
    }
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



// Btn Action -------------------------------------//

// PostTableViewHeaderView Delegate BtnAction -----//

// Back Btn Action
- (void)backBtnAction {
    // Pop
    [self.navigationController popViewControllerAnimated:YES];
}

// Add Post Btn Action
- (void)addPostBtnAction {
    // Make Post
    UIStoryboard *makeStoryBoard = [UIStoryboard storyboardWithName:@"Make" bundle:nil];
    PostMakeViewController *postMakeVC = [makeStoryBoard instantiateViewControllerWithIdentifier:@"PostMakeViewController"];

    [postMakeVC setMakeModeWithPinPK:self.pinData.pk];      // pin_pk 전달해줘야 포스트 생성가능
    postMakeVC.wasPostView = YES;       // post뷰에서 이동
    
    [self presentViewController:postMakeVC animated:YES completion:nil];
}


// Edit Btn Action
- (void)editBtnAction:(NSInteger)index {
    NSLog(@"editBtnAction");
    
    // 포스트 수정
    UIStoryboard *makeStoryBoard = [UIStoryboard storyboardWithName:@"Make" bundle:nil];
    PostMakeViewController *postMakeVC = [makeStoryBoard instantiateViewControllerWithIdentifier:@"PostMakeViewController"];
    
    [postMakeVC setEditModeWithPostData:self.pinData.pin_post_list[index]];   // 수정 모드, 데이터 세팅
    postMakeVC.wasPostView = YES;       // post뷰에서 이동
    
    [self presentViewController:postMakeVC animated:YES completion:nil];
    
}



@end


