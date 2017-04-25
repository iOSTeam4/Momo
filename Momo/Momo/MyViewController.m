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
#import "PinPostViewController.h"

#import "MapMakeViewController.h"
#import "PinMakeViewController.h"

#define SHOW_MAP 0
#define SHOW_PIN 1

@interface MyViewController ()
<UITableViewDelegate, UITableViewDataSource, UserProfileHeaderViewDelegate, MapProfileTableViewCellDelegate, PinProfileTableViewCellDelegate, UIGestureRecognizerDelegate>

@property (nonatomic) NSInteger mapPinNum;

@property (nonatomic) UIRefreshControl *tableViewRefreshControl;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@end

@implementation MyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // TableView Settings -------------------//

    // TableView Nib(xib) Register
    [self initialTableViewCellSettingWithNib];
    
    self.tableView.showsVerticalScrollIndicator = NO;       // 스크롤 라인 indicator Hidden
    
    self.mapPinNum = SHOW_MAP;     // 처음에 Map을 기본으로 보여줌
    
    // TableView Header, Cell Height 자동 적용
    self.tableView.estimatedSectionHeaderHeight = 260;
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
    
    // Navi Pop Gesture 활성화, 아래 gestureRecognizerShouldBegin와 세트
    [self.navigationController.interactivePopGestureRecognizer setDelegate:self];
    
    // 반드시 테이블 뷰 refresh 해야함
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // always 1 : userProfile
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    UserProfileHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"userProfileHeader"];
    headerView.delegate = self;
    
    // 데이터 세팅
    if ([DataCenter sharedInstance].momoUserData.user_profile_image_data) {
        headerView.userImgView.image  = [[DataCenter sharedInstance].momoUserData getUserProfileImage];  // 프사
    }
    if ([DataCenter sharedInstance].momoUserData.user_username) {
        headerView.userNameLabel.text = [DataCenter sharedInstance].momoUserData.user_username;       // 이름
    }
//    if ([DataCenter sharedInstance].momoUserData.user_id) {
//        headerView.userIDLabel.text   = [NSString stringWithFormat:@"@%@", [DataCenter sharedInstance].momoUserData.user_id]; // 아이디
//    }
    
    return headerView;
}


#pragma mark - Rows Settings

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.mapPinNum == SHOW_MAP) {
        return [DataCenter sharedInstance].momoUserData.user_map_list.count;
        
    } else {
        return [MomoPinDataSet allObjects].count;
//        return ((MomoMapDataSet *)([DataCenter sharedInstance].momoUserData.user_map_list[0])).map_pin_list.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"cellForRowAtIndexPath mapPinNum : %ld, indexPath : %ld", self.mapPinNum, indexPath.row);
    
    if (self.mapPinNum == SHOW_MAP) {
        MapProfileTableViewCell *mapCell = [tableView dequeueReusableCellWithIdentifier:@"mapProfileCell" forIndexPath:indexPath];
        
        // 지도 데이터 역순 적용
        NSInteger inverseOrderIndex = [DataCenter sharedInstance].momoUserData.user_map_list.count - 1 - indexPath.row;
        
        [mapCell initWithMapIndex:inverseOrderIndex];
        mapCell.delegate = self;        // 델리게이트 설정
        
        return mapCell;
        
    } else  {
        PinProfileTableViewCell *pinCell = [tableView dequeueReusableCellWithIdentifier:@"pinProfileCell" forIndexPath:indexPath];
        
        // 핀 데이터 역순 적용
        NSInteger inverseOrderIndex = [MomoPinDataSet allObjects].count - 1 - indexPath.row;
        
        [pinCell initWithPinIndex:inverseOrderIndex];
        pinCell.delegate = self;    // 델리게이트 설정
        
        return pinCell;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.mapPinNum == SHOW_MAP) {
        // 선택 지도 보기
        UIStoryboard *makeStoryBoard = [UIStoryboard storyboardWithName:@"Map" bundle:nil];
        MapViewController *mapVC = [makeStoryBoard instantiateViewControllerWithIdentifier:@"MapViewController"];
        
        // 지도 데이터 역순 적용
        NSInteger inverseOrderIndex = [DataCenter sharedInstance].momoUserData.user_map_list.count - 1 - indexPath.row;
        
        [mapVC showSelectedMapAndSetMapData:[DataCenter myMapList][inverseOrderIndex]];         // 지도 데이터 세팅
        
        [self.navigationController pushViewController:mapVC animated:YES];
        
    } else {
        // 선택 핀 보기
        UIStoryboard *pinViewStoryBoard = [UIStoryboard storyboardWithName:@"PinView" bundle:nil];
        PinViewController *pinVC = [pinViewStoryBoard instantiateInitialViewController];

        // 핀 데이터 역순 적용
        NSInteger inverseOrderIndex = [MomoPinDataSet allObjects].count - 1 - indexPath.row;

        [pinVC showSelectedPinAndSetPinData:[MomoPinDataSet allObjects][inverseOrderIndex]];    // 핀 데이터 세팅
        
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
    
    UIStoryboard *pinViewStoryBoard = [UIStoryboard storyboardWithName:@"PinView" bundle:nil];
    PinViewController *pinVC = [pinViewStoryBoard instantiateInitialViewController];
    
    // 핀 데이터 세팅
    [pinVC showSelectedPinAndSetPinData:pinData];    // 선택 핀 보기
    
    [self.navigationController pushViewController:pinVC animated:YES];
}

// 포스트 보기
- (void)showSelectedPost:(MomoPostDataSet *)postData {

    UIStoryboard *pinViewStoryBoard = [UIStoryboard storyboardWithName:@"PinView" bundle:nil];
    PinPostViewController *postVC = [pinViewStoryBoard instantiateViewControllerWithIdentifier:@"PinPostViewController"];

    // 포스트 데이터 세팅
    [postVC showSelectedPostAndSetPostData:postData];   // 선택 포스트 보기
    
    [self.navigationController pushViewController:postVC animated:YES];
    
}


- (void)selectedMapEditBtnWithIndex:(NSInteger)index {
    NSLog(@"selectedMapEditBtnWithIndex, %ld", index);
    
    // 선택 지도 수정
    UIStoryboard *makeStoryBoard = [UIStoryboard storyboardWithName:@"Make" bundle:nil];
    MapMakeViewController *mapMakeVC = [makeStoryBoard instantiateViewControllerWithIdentifier:@"MapMakeViewController"];
    
    [mapMakeVC setEditModeWithMapData:[DataCenter myMapList][index]];   // 수정 모드, 데이터 세팅
    [self presentViewController:mapMakeVC animated:YES completion:nil];
    
}

//  PinProfileTableViewCell Delegate Methods -------------------//
#pragma mark - PinProfileTableViewCell Delegate Methods

- (void)selectedPinEditBtnWithIndex:(NSInteger)index {
    NSLog(@"selectedPinEditBtnWithIndex, %ld", index);
    
    // 선택 핀 수정
    UIStoryboard *makeStoryBoard = [UIStoryboard storyboardWithName:@"Make" bundle:nil];
    PinMakeViewController *pinMakeVC = [makeStoryBoard instantiateViewControllerWithIdentifier:@"PinMakeViewController"];
    
    [pinMakeVC setEditModeWithPinData:[MomoPinDataSet allObjects][index]];   // 수정 모드, 데이터 세팅
    [self presentViewController:pinMakeVC animated:YES completion:nil];
    
}


@end
