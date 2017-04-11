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

@interface MyViewController () <UITableViewDelegate, UITableViewDataSource, UserProfileHeaderViewDelegate>

@property (nonatomic) NSArray *mapPinDataArr;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSInteger mapPinNum;

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
                                                          
                                                          [NetworkModule logOutRequestWithCompletionBlock:^(BOOL isSuccess, NSDictionary *result) {
                                                              if (isSuccess) {
                                                                  NSLog(@"log out success");
                                                                  
                                                              } else {
                                                                  NSLog(@"log out fail");
                                                              }
                                                          }];
                                                          
                                                          // 블럭에 넣어 기다리지 않고, 바로 로그아웃
                                                          UIStoryboard *loginStoryboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
                                                          UIViewController *loginController = [loginStoryboard instantiateInitialViewController];
                                                          
                                                          [[UIApplication sharedApplication].keyWindow setRootViewController:loginController];
                                                          [[UIApplication sharedApplication].keyWindow makeKeyAndVisible];

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
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    NSLog(@"heightForHeaderInSection");
    return 260;
}


#pragma mark - Rows Settings

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ((NSArray *)self.mapPinDataArr[self.mapPinNum]).count;
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
    
    UITableViewCell *cell;
    
    if (self.mapPinNum == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"mapProfileCell" forIndexPath:indexPath];
    } else if (self.mapPinNum == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"pinProfileCell" forIndexPath:indexPath];
    }
    
    return cell;
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
