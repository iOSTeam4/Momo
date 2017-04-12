//
//  MyViewController.m
//  Momo
//
//  Created by Jeheon Choi on 2017. 4. 4..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import "MyViewController.h"
#import "UserProfileHeaderView.h"
#import "UserAccountEditViewController.h"

#import "MapProfileTableViewCell.h"
#import "PinProfileTableViewCell.h"

@interface MyViewController () <UITableViewDelegate, UITableViewDataSource, UserProfileHeaderViewDelegate>

@property (nonatomic) NSArray *mapPinDataArr;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSInteger mapPinNum;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@end

@implementation MyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:@"My View"];
    
    // Navi Bar 오른쪽 설정 버튼
    UIBarButtonItem *naviRightBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"lockOpen"] style:UIBarButtonItemStylePlain target:self action:@selector(selectedNaviRightBtn)];    // 이미지 수정 필요
    [self.navigationItem setRightBarButtonItem:naviRightBtn];
    
    [self initialTableViewCellSettingWithNib];
    
    self.mapPinNum = 0;     // 처음에 Map을 기본으로 보여줌
    
    self.mapPinDataArr = @[@[@[@"map1"], @[@"map2"], @[@"map3"], @[@"map4"]],
                           @[@[@"pin1"], @[@"pin2"], @[@"pin3"], @[@"pin4"], @[@"pin5"], @[@"pin6"]]];

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
                                                          NSLog(@"Log Out");
                                                          
                                                          [self.indicator startAnimating];
                                                          
                                                          [NetworkModule logOutRequestWithCompletionBlock:^(BOOL isSuccess, NSDictionary *result) {
                                                              [self.indicator stopAnimating];
                                                              
                                                              if (isSuccess) {
                                                                  NSLog(@"log out success");
                                                                  UIStoryboard *loginStoryboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
                                                                  UIViewController *loginController = [loginStoryboard instantiateInitialViewController];
                                                                  
                                                                  [[UIApplication sharedApplication].keyWindow setRootViewController:loginController];
                                                                  [[UIApplication sharedApplication].keyWindow makeKeyAndVisible];
                                                                  
                                                              } else {
                                                                  NSLog(@"log out fail");
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
    // always 1 : MapProfile or PinProfile
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    UserProfileHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"userProfileHeader"];
    headerView.delegate = self;
    
    // 데이터 세팅   (일단 데이터가 없어 이쁘지 않으니, 이렇게라도..)
    if ([DataCenter sharedInstance].momoUserData.user_profile_image) {
        headerView.userImgView.image  = [DataCenter sharedInstance].momoUserData.user_profile_image;  // 프사
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
        return ((MomoMapDataSet *)([DataCenter sharedInstance].momoUserData.user_map_list[0])).map_pin_list.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"heightForRowAtIndexPath");
    
    // Cell Height 해상도 별 제대로 조정 필요
    if (self.mapPinNum == 0) {
        return 320;
    } else {        // mapPinNum : 1
        return 250;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"cellForRowAtIndexPath mapPinNum : %ld, indexPath : %ld", self.mapPinNum, indexPath.row);
    
    if (self.mapPinNum == 0) {
        MapProfileTableViewCell *mapCell = [tableView dequeueReusableCellWithIdentifier:@"mapProfileCell" forIndexPath:indexPath];
        
        // 데이터 세팅   (일단 데이터가 없어 이쁘지 않으니, 이렇게라도..)
        if ([DataCenter sharedInstance].momoUserData.user_profile_image) {
            mapCell.userImgView.image  = [DataCenter sharedInstance].momoUserData.user_profile_image;  // 프사
        }
        if ([DataCenter sharedInstance].momoUserData.user_username) {
            mapCell.userNameLabel.text = [DataCenter sharedInstance].momoUserData.user_username;       // 이름
        }
        
        mapCell.mapNameLabel.text = ((MomoMapDataSet *)([DataCenter sharedInstance].momoUserData.user_map_list[indexPath.row])).map_name;
        
        return mapCell;
        
    } else  {
        PinProfileTableViewCell *pinCell = [tableView dequeueReusableCellWithIdentifier:@"pinProfileCell" forIndexPath:indexPath];
        
        // 데이터 세팅   (일단 데이터가 없어 이쁘지 않으니, 이렇게라도..)
        if ([DataCenter sharedInstance].momoUserData.user_profile_image) {
            pinCell.userImgView.image  = [DataCenter sharedInstance].momoUserData.user_profile_image;  // 프사
        }
        if ([DataCenter sharedInstance].momoUserData.user_username) {
            pinCell.userNameLabel.text = [DataCenter sharedInstance].momoUserData.user_username;       // 이름
        }
        
        pinCell.pinNameLabel.text = ((MomoPinDataSet *)((MomoMapDataSet *)([DataCenter sharedInstance].momoUserData.user_map_list[0])).map_pin_list[indexPath.row]).pin_name;
        
        return pinCell;
    }
}


//  UserProfileHeaderView Delegate Methods -------------------//
#pragma mark - UserProfileHeaderView Delegate Methods

- (void)selectedUserEditBtn {
    [self performSegueWithIdentifier:@"userProfileEditSegue" sender:self];
}

- (void)selectedMapPinBtnWithNum:(NSInteger)num {
    self.mapPinNum = num;
    [self.tableView reloadData];
}


@end
