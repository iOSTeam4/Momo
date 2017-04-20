//
//  MainViewController.m
//  Momo
//
//  Created by Jeheon Choi on 2017. 3. 27..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import "MainViewController.h"
#import "MainTabBarController.h"
#import "MainMapTableViewCell.h"
#import "MainPinCollectionCell.h"
#import "MainUserCollectionCell.h"

@interface MainViewController ()
<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (nonatomic) UISearchBar *searchBar;

@property (nonatomic) NSArray *mainMapArray;
@property (nonatomic) NSArray *mainUserArray;

@end


@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:@"Main View"];
    
    [self initialNaviBarSetting];               // NaviBar 초기세팅
    [self initialSearchBarSetting];             // SearchBar 초기세팅

    
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.frame];
//    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [self.view addSubview:tableView];
    
    // Nib Resister
    UINib *mapCellNib = [UINib nibWithNibName:@"MainMapTableViewCell" bundle:nil];
    [tableView registerNib:mapCellNib forCellReuseIdentifier:@"mapTableViewCell"];
    
    tableView.delegate = self;
    tableView.dataSource = self;
    
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [GoogleAnalyticsModule startGoogleAnalyticsTrackingWithScreenName:@"MainViewController"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

// NaviBar, SearchBar 세팅 ----------------------------//

- (void)initialNaviBarSetting {
    
    // Navi Bar 오른쪽 설정 버튼
    UIBarButtonItem *naviRightBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(selectedNaviRightBtn)];
    [self.navigationItem setRightBarButtonItem:naviRightBtn];
}

- (void)initialSearchBarSetting {

    // UISearchBar
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.delegate = self;
    
    UITextField *searchTextField = [self.searchBar valueForKey:@"searchField"];
    searchTextField.backgroundColor = [UIColor mm_paleGreyColor];    // searchBar backgroundColor
    searchTextField.textColor = [UIColor mm_brightSkyBlueColor];     // searchBar textColor
    searchTextField.font = [UIFont boldSystemFontOfSize:14];         // searchBar font
    self.searchBar.placeholder = @"지도 또는 사람 찾아보기";               // searchBar placeholder
    
}

// NaviBar right Btn Selector Method
- (void)selectedNaviRightBtn {
    
    self.navigationItem.titleView = self.searchBar;      // 네비바에 서치바 배치
    
    // Navi Bar 오른쪽 취소 버튼
    UIBarButtonItem *searchBarCancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(searchBarCancelBtn)];
    self.navigationItem.rightBarButtonItem = nil;
    [self.navigationItem setRightBarButtonItem:searchBarCancelBtn];

}

// 취소버튼 눌렀을 때
- (void)searchBarCancelBtn {
    
    self.navigationItem.titleView = nil;    // 서치바 없애기
    self.navigationItem.rightBarButtonItem = nil;
    [self initialNaviBarSetting];           // 다시 초기 네비바 버튼들 세팅
}


// ---------------------------------------------------------------- //
#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 250;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MainMapTableViewCell *mapTableViewCell = [tableView dequeueReusableCellWithIdentifier:@"mapTableViewCell" forIndexPath:indexPath];
    
    return mapTableViewCell;
}



//-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    
//    switch (section) {
//        case 0:
//        {
//            MainMapCollectionCell *mapCell = [tableView dequeueReusableCellWithIdentifier:@"MainMapCollectionCell"];
//            mapCell.titleLabel.text = @"인기 지도";
//            return mapCell;
//            break;
//        }
//        case 1:
//        {
//            MainMapCollectionCell *mapCell = [tableView dequeueReusableCellWithIdentifier:@"MainMapCollectionCell"];
//            mapCell.titleLabel.text = @"새로운 핀";
//            return mapCell;
//            break;
//        }
//        default:
//        {
//            MainMapCollectionCell *mapCell = [tableView dequeueReusableCellWithIdentifier:@"MainMapCollectionCell"];
//            mapCell.titleLabel.text = @"모모 스타";
//            return mapCell;
//            break;
//        }
//    }
//}

@end


