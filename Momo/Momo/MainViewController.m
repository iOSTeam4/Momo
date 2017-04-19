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
<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) NSArray *mainMapArray;
@property (nonatomic) NSArray *mainUserArray;

@end


@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:@"Main View"];
    
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


// ---------------------------------------------------------------- //
#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 200;
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


