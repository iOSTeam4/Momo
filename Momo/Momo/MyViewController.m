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

#import "MapMakeViewController.h"
#import "PinMakeViewController.h"

@interface MyViewController ()
<UITableViewDelegate, UITableViewDataSource, UserProfileHeaderViewDelegate, MapProfileTableViewCellDelegate, PinProfileTableViewCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSInteger mapPinNum;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@end

@implementation MyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:@"My View"];
    
    // Navi Bar 오른쪽 설정 버튼
    UIBarButtonItem *naviRightBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings"] style:UIBarButtonItemStylePlain target:self action:@selector(selectedNaviRightBtn)];
    [self.navigationItem setRightBarButtonItem:naviRightBtn];
    
    
    [self initialTableViewCellSettingWithNib];
    
    self.mapPinNum = 0;     // 처음에 Map을 기본으로 보여줌
    
    
    // TableViewCell Height 자동 적용
    self.tableView.estimatedRowHeight = 300;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 반드시 테이블 뷰 refresh 해야함
    [self.tableView reloadData];
}


// NaviBar Hidden 상황 & PopGestureRecognizer 사용 예외처리
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    NSLog(@"MyViewController : gestureRecognizerShouldBegin, %ld", self.navigationController.viewControllers.count);
    
    // NaviController RootViewController에서는 PopGesture 실행 안되도록 처리 (다른 Gesture 쓰는 것 없음)
    if(self.navigationController.viewControllers.count > 1){
        return YES;
    }
    return NO;
}


- (void)selectedNaviRightBtn {
    NSLog(@"selectedNaviRightBtn");
    
    
    UIAlertController *alertSetting = [UIAlertController alertControllerWithTitle:nil
                                                                          message:nil
                                                                   preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *accountSettingBtn = [UIAlertAction actionWithTitle:@"Account Setting"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * _Nonnull action) {
                                                                  NSLog(@"Account Setting");
                                                                  
                                                                  UserAccountEditViewController *UserAccountEditVC = [[UserAccountEditViewController alloc] init];
                                                                  [self.navigationController pushViewController:UserAccountEditVC animated:YES];
                                                              }];
    
    UIAlertAction *logOutBtn = [UIAlertAction actionWithTitle:@"Log Out"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
                                                          
                                                          [self.indicator startAnimating];
                                                          
                                                          [NetworkModule logOutRequestWithCompletionBlock:^(BOOL isSuccess, NSString *result) {
                                                              [self.indicator stopAnimating];
                                                              
                                                              if (isSuccess) {
                                                                  NSLog(@"log out success : %@", result);
                                                                  
                                                                  UIStoryboard *loginStoryboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
                                                                  UIViewController *loginController = [loginStoryboard instantiateInitialViewController];
                                                                  
                                                                  [[UIApplication sharedApplication].keyWindow setRootViewController:loginController];
                                                                  [[UIApplication sharedApplication].keyWindow makeKeyAndVisible];
                                                                  
                                                              } else {
                                                                  NSLog(@"error : %@", result);
                                                                  
                                                                  UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"oops!"
                                                                                                                                           message:result
                                                                                                                                    preferredStyle:UIAlertControllerStyleAlert];
                                                                  
                                                                  UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"확인"
                                                                                                                     style:UIAlertActionStyleDefault
                                                                                                                   handler:nil];
                                                                  [alertController addAction:okButton];
                                                                  [self presentViewController:alertController animated:YES completion:nil];
                                                              }
                                                          }];
                                                      }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleCancel
                                                   handler:nil];
    
    
    [alertSetting addAction:accountSettingBtn];
    [alertSetting addAction:logOutBtn];
    [alertSetting addAction:cancel];
    [self presentViewController:alertSetting animated:YES completion:nil];
    
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


// UITableViewDataSource Methods -------------------------------//
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
    if ([DataCenter sharedInstance].momoUserData.user_id) {
        headerView.userIDLabel.text   = [NSString stringWithFormat:@"@%@", [DataCenter sharedInstance].momoUserData.user_id]; // 아이디
    }
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    NSLog(@"heightForHeaderInSection");
    return 260;
}


#pragma mark - Rows Settings

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.mapPinNum == 0) {
        return [DataCenter sharedInstance].momoUserData.user_map_list.count;
    } else {
        return [MomoPinDataSet allObjects].count;
//        return ((MomoMapDataSet *)([DataCenter sharedInstance].momoUserData.user_map_list[0])).map_pin_list.count;
    }
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
////    NSLog(@"heightForRowAtIndexPath");
//    
//    // Cell Height 해상도 별 제대로 조정 필요
//    if (self.mapPinNum == 0) {
//        return 320;
//    } else {        // mapPinNum : 1
//        return 250;
//    }
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"cellForRowAtIndexPath mapPinNum : %ld, indexPath : %ld", self.mapPinNum, indexPath.row);
    
    if (self.mapPinNum == 0) {
        MapProfileTableViewCell *mapCell = [tableView dequeueReusableCellWithIdentifier:@"mapProfileCell" forIndexPath:indexPath];
        mapCell.tag = indexPath.row;    // 태그 설정
        
//        // 델리게이터 설정되어있는 셀인지?
//        if (!mapCell.delegate) {
            mapCell.delegate = self;
//        }
        

        
        // 데이터 세팅
        if ([DataCenter sharedInstance].momoUserData.user_profile_image_data) {
            mapCell.userImgView.image  = [[DataCenter sharedInstance].momoUserData getUserProfileImage];  // 프사
        }
        if ([DataCenter sharedInstance].momoUserData.user_username) {
            mapCell.userNameLabel.text = [DataCenter sharedInstance].momoUserData.user_username;       // 이름
        }
        
        [mapCell.mapNameBtn setTitle:[DataCenter myMapList][indexPath.row].map_name forState:UIControlStateNormal];

        if ([DataCenter myMapList][indexPath.row].map_is_private) {  // 비밀지도일때 자물쇠 아이콘 추가
            [mapCell.mapNameBtn setImage:[UIImage imageNamed:@"lockBtnClose"] forState:UIControlStateNormal];
            [mapCell.mapNameBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
            [mapCell.mapNameBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 2.5, 0, 0)];
        }
        
        mapCell.mapPinNumLabel.text = [NSString stringWithFormat:@"%ld", [DataCenter myMapList][indexPath.row].map_pin_list.count];
        
        return mapCell;
        
    } else  {
        PinProfileTableViewCell *pinCell = [tableView dequeueReusableCellWithIdentifier:@"pinProfileCell" forIndexPath:indexPath];
        pinCell.tag = indexPath.row;    // 태그 설정

        // 델리게이터 설정되어있는 셀인지?
        if (!pinCell.delegate) {
            pinCell.delegate = self;
        }
        
        // 데이터 세팅
        if ([DataCenter sharedInstance].momoUserData.user_profile_image_data) {
            pinCell.userImgView.image  = [[DataCenter sharedInstance].momoUserData getUserProfileImage];  // 프사
        }
        if ([DataCenter sharedInstance].momoUserData.user_username) {
            pinCell.userNameLabel.text = [DataCenter sharedInstance].momoUserData.user_username;       // 이름
        }
        
        pinCell.pinNameLabel.text = ((MomoPinDataSet *)([MomoPinDataSet allObjects][indexPath.row])).pin_name;
        
        return pinCell;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.mapPinNum == 0) {
        // 선택지도 보기
        UIStoryboard *makeStoryBoard = [UIStoryboard storyboardWithName:@"Map" bundle:nil];
        MapViewController *mapVC = [makeStoryBoard instantiateViewControllerWithIdentifier:@"MapViewController"];
        
        [mapVC showSelectedMapAndSetMapData:[DataCenter myMapList][indexPath.row]];
        
        [self.navigationController pushViewController:mapVC animated:YES];
        
    } else {
        // 선택핀 보기
        
        // 사용자 모든 핀 정보 넣어서 전달
        MomoMapDataSet *mapData = [[MomoMapDataSet alloc] init];
        [mapData.map_pin_list addObjects:[MomoPinDataSet allObjects]];
        
        UIStoryboard *pinViewStoryBoard = [UIStoryboard storyboardWithName:@"PinView" bundle:nil];
        PinViewController *pinVC = [pinViewStoryBoard instantiateInitialViewController];
        
        // 핀 데이터 세팅
        [pinVC showSelectedPinAndSetMapData:mapData withPinIndex:indexPath.row];
        
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

- (void)selectedMapEditBtnWithIndex:(NSInteger)index {
    NSLog(@"selectedMapEditBtnWithIndex, %ld", index);
    
    // 선택 지도 수정
    UIStoryboard *makeStoryBoard = [UIStoryboard storyboardWithName:@"Make" bundle:nil];
    MapMakeViewController *mapMakeVC = [makeStoryBoard instantiateViewControllerWithIdentifier:@"MapMakeViewController"];
    
    [mapMakeVC setEditModeWithMapData:[DataCenter myMapList][index]];   // 수정 모드, 데이터 세팅
    [self.navigationController pushViewController:mapMakeVC animated:YES];
    
}

//  PinProfileTableViewCell Delegate Methods -------------------//
#pragma mark - PinProfileTableViewCell Delegate Methods

- (void)selectedPinEditBtnWithIndex:(NSInteger)index {
    NSLog(@"selectedPinEditBtnWithIndex, %ld", index);
}


@end
