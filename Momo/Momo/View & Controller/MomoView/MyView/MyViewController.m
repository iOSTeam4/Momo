//
//  MyViewController.m
//  Momo
//
//  Created by Jeheon Choi on 2017. 4. 4..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import "MyViewController.h"
#import "FollowViewController.h"
#import "UserAccountEditViewController.h"

#import "UserProfileHeaderView.h"
#import "MapProfileTableViewCell.h"
#import "PinProfileTableViewCell.h"

#import "MapViewController.h"
#import "PinViewController.h"
#import "PostViewController.h"

#import "MapMakeViewController.h"
#import "PinMakeViewController.h"

#define SHOW_MAP 0
#define SHOW_PIN 1

@interface MyViewController ()
<UITableViewDelegate, UITableViewDataSource, UserProfileHeaderViewDelegate, MapProfileTableViewCellDelegate, PinProfileTableViewCellDelegate, UIGestureRecognizerDelegate>

@property (nonatomic) NSInteger mapPinNum;

@property (nonatomic) UIRefreshControl *tableViewRefreshControl;

@end

@implementation MyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Navi Pop Gesture 활성화, 아래 gestureRecognizerShouldBegin와 세트
    [self.navigationController.interactivePopGestureRecognizer setDelegate:self];

    
    // TableView Settings -------------------//

    // TableView Nib(xib) Register
    [self initialTableViewCellSettingWithNib];
    
    self.mapPinNum = SHOW_MAP;     // 처음에 Map을 기본으로 보여줌
    
    // TableView Header, Cell Height 자동 적용
    self.tableView.estimatedSectionHeaderHeight = 245;
    self.tableView.sectionHeaderHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 300;
    self.tableView.rowHeight = UITableViewAutomaticDimension;

    // TableView RefreshControl 설정
    self.tableViewRefreshControl = [[UIRefreshControl alloc] init];
    [self.tableView addSubview:self.tableViewRefreshControl];
    [self.tableViewRefreshControl addTarget:self action:@selector(refreshTableView) forControlEvents:UIControlEventValueChanged];
    
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [GoogleAnalyticsModule startGoogleAnalyticsTrackingWithScreenName:@"MyViewController"];
    
    // 데이터 변경되었을 때, 바로 반영되어야하므로 viewWillAppear할 때마다 테이블 뷰 refresh
    [self.tableView reloadData];
}


// NaviBar Hidden 상황 & PopGestureRecognizer 사용 예외처리
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    NSLog(@"MyViewController : gestureRecognizerShouldBegin, %ld", self.navigationController.viewControllers.count);
    
    // NaviController RootViewController에서는 PopGesture 실행 안되도록 처리
    if(self.navigationController.viewControllers.count > 1){
        return YES;
    }
    return NO;
}

// RefeshControl Method
- (void)refreshTableView {
    [self.tableViewRefreshControl endRefreshing];
    
    // 서버 네트웍 통신 들어갈 부분
    [self.tableView reloadData];
}


// TableView Methods -------------------------------------------//

- (void)initialTableViewCellSettingWithNib {
    
    // User Profile Header
    UINib *userProfileHeaderNib = [UINib nibWithNibName:@"UserProfileHeaderView" bundle:nil];
    [self.tableView registerNib:userProfileHeaderNib forHeaderFooterViewReuseIdentifier:@"userProfileHeader"];

    
    // User Map & Pin Cells
    UINib *mapCellNib = [UINib nibWithNibName:@"MapProfileTableViewCell" bundle:nil];
    [self.tableView registerNib:mapCellNib forCellReuseIdentifier:@"mapProfileCell"];
    UINib *pinCellNib = [UINib nibWithNibName:@"PinProfileTableViewCell" bundle:nil];
    [self.tableView registerNib:pinCellNib forCellReuseIdentifier:@"pinProfileCell"];
}


// UITableViewDataSource Methods -----//
#pragma mark - Section Header Settings

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    UserProfileHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"userProfileHeader"];
    headerView.delegate = self;
    
    // 유저 데이터 세팅
    if ([DataCenter sharedInstance].momoUserData.user_author.profile_img_data) {
        headerView.userImgView.image  = [[DataCenter sharedInstance].momoUserData.user_author getAuthorProfileImg];         // 프사
    }
    
    headerView.userNameLabel.text = [DataCenter sharedInstance].momoUserData.user_author.username;                          // 이름
    headerView.userIDLabel.text   = [NSString stringWithFormat:@"@%@", [DataCenter sharedInstance].momoUserData.user_id];   // 아이디
    
    if ([DataCenter sharedInstance].momoUserData.user_description) {
        headerView.userCommentLabel.text = [DataCenter sharedInstance].momoUserData.user_description;                       // 유저 코멘트
    }

    
    return headerView;
}


#pragma mark - Rows Settings

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.mapPinNum == SHOW_MAP) {
        return [DataCenter myMapList].count;
        
    } else {
        return [DataCenter myPinList].count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"cellForRowAtIndexPath mapPinNum : %ld, indexPath : %ld", self.mapPinNum, indexPath.row);
    
    if (self.mapPinNum == SHOW_MAP) {
        MapProfileTableViewCell *mapCell = [tableView dequeueReusableCellWithIdentifier:@"mapProfileCell" forIndexPath:indexPath];
        
        // 지도 데이터 세팅
        [mapCell initWithMapData:[DataCenter myMapList][indexPath.row]];
        mapCell.delegate = self;        // 델리게이트 설정
        
        return mapCell;
        
    } else  {
        PinProfileTableViewCell *pinCell = [tableView dequeueReusableCellWithIdentifier:@"pinProfileCell" forIndexPath:indexPath];
        
        // 핀 데이터 세팅
        [pinCell initWithPinData:[DataCenter myPinList][indexPath.row]];
        pinCell.delegate = self;    // 델리게이트 설정
        
        return pinCell;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.mapPinNum == SHOW_MAP) {
        // 선택 지도 보기
        UIStoryboard *makeStoryBoard = [UIStoryboard storyboardWithName:@"Map" bundle:nil];
        MapViewController *mapVC = [makeStoryBoard instantiateViewControllerWithIdentifier:@"MapViewController"];
        
        [mapVC showSelectedMapAndSetMapData:[DataCenter myMapList][indexPath.row]];         // 지도 데이터 세팅
        
        [self.navigationController pushViewController:mapVC animated:YES];
        
    } else {
        // 선택 핀 보기
        UIStoryboard *pinPostStoryBoard = [UIStoryboard storyboardWithName:@"PinPost" bundle:nil];
        PinViewController *pinVC = [pinPostStoryBoard instantiateInitialViewController];

        [pinVC showSelectedPinAndSetPinData:[DataCenter myPinList][indexPath.row]];    // 핀 데이터 세팅
        
        [self.navigationController pushViewController:pinVC animated:YES];
    }
}


//  UserProfileHeaderView Delegate Methods -------------------//
#pragma mark - UserProfileHeaderView Delegate Methods

- (void)selectedFollowerBtn {
    FollowViewController *followVC = [self.storyboard instantiateViewControllerWithIdentifier:@"FollowViewController"];
    
    // VC 값 세팅, 전달
    followVC.title = @"팔로워";
    [self.navigationController pushViewController:followVC animated:YES];
}

- (void)selectedFollowingBtn {
    FollowViewController *followVC = [self.storyboard instantiateViewControllerWithIdentifier:@"FollowViewController"];

    // VC 값 세팅, 전달
    followVC.title = @"팔로잉";
    [self.navigationController pushViewController:followVC animated:YES];

}

- (void)selectedUserEditBtn {
    [self performSegueWithIdentifier:@"userProfileEditSegue" sender:self];
}

- (void)selectedMapPinBtnWithNum:(NSInteger)num {
    self.mapPinNum = num;
    [self.tableView reloadData];
}


//  MapProfileTableViewCell Delegate Methods -------------------//
#pragma mark - MapProfileTableViewCell Delegate Methods


// 해당 지도 보기 & 핀 생성 유도
- (void)showSelectedMapAndMakePin:(MomoMapDataSet *)mapData {
    
    UIStoryboard *makeStoryBoard = [UIStoryboard storyboardWithName:@"Map" bundle:nil];
    MapViewController *mapVC = [makeStoryBoard instantiateViewControllerWithIdentifier:@"MapViewController"];
    
    [mapVC showSelectedMapAndSetMapData:mapData];       // 선택 지도 보기
    
    [self.navigationController pushViewController:mapVC animated:YES];
    [mapVC makePinByMakePinBtn];    // 내 위치로 핀 찍기

}

// 핀 보기
- (void)showSelectedPin:(MomoPinDataSet *)pinData {
    
    UIStoryboard *pinPostStoryBoard = [UIStoryboard storyboardWithName:@"PinPost" bundle:nil];
    PinViewController *pinVC = [pinPostStoryBoard instantiateInitialViewController];
    
    // 핀 데이터 세팅
    [pinVC showSelectedPinAndSetPinData:pinData];    // 선택 핀 보기
    
    [self.navigationController pushViewController:pinVC animated:YES];
}

// 포스트 보기
- (void)showSelectedPost:(MomoPostDataSet *)postData {

    UIStoryboard *pinPostStoryBoard = [UIStoryboard storyboardWithName:@"PinPost" bundle:nil];
    PostViewController *postVC = [pinPostStoryBoard instantiateViewControllerWithIdentifier:@"PostViewController"];

    // 포스트 데이터 세팅
    [postVC showSelectedPostAndSetPostData:postData];   // 선택 포스트 보기
    
    [self.navigationController pushViewController:postVC animated:YES];
    
}


- (void)selectedMapEditBtnWithMapData:(MomoMapDataSet *)mapData {
    NSLog(@"selectedMapEditBtnWithMapData, %@", mapData);
    
    // 선택 지도 수정
    UIStoryboard *makeStoryBoard = [UIStoryboard storyboardWithName:@"Make" bundle:nil];
    MapMakeViewController *mapMakeVC = [makeStoryBoard instantiateViewControllerWithIdentifier:@"MapMakeViewController"];
    
    [mapMakeVC setEditModeWithMapData:mapData];   // 수정 모드, 데이터 세팅
    [self presentViewController:mapMakeVC animated:YES completion:nil];
    
}

//  PinProfileTableViewCell Delegate Methods -------------------//
#pragma mark - PinProfileTableViewCell Delegate Methods

- (void)selectedPinEditBtnWithPinData:(MomoPinDataSet *)pinData {
    NSLog(@"selectedPinEditBtnWithPinData, %@", pinData);
    
    // 선택 핀 수정
    UIStoryboard *makeStoryBoard = [UIStoryboard storyboardWithName:@"Make" bundle:nil];
    PinMakeViewController *pinMakeVC = [makeStoryBoard instantiateViewControllerWithIdentifier:@"PinMakeViewController"];
    
    [pinMakeVC setEditModeWithPinData:pinData];   // 수정 모드, 데이터 세팅
    [self presentViewController:pinMakeVC animated:YES completion:nil];
    
}


@end
