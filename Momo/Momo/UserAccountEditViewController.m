//
//  UserAccountEditViewController.m
//  Momo
//
//  Created by Jeheon Choi on 2017. 4. 9..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import "UserAccountEditViewController.h"

@interface UserAccountEditViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) UITableView *settingTableView;

@property (nonatomic) NSArray *settingArr;

@end


@implementation UserAccountEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self setSettingTableView];
}

- (void)setSettingTableView {
    
    self.settingArr = @[@[@"내 계정", @"정보", @""],     // Section title
                        @[  // row  @[cell type , text]
                            @[@[@1, @"아이디", @"pikapika"], @[@1, @"이메일"], @[@1, @"비밀번호"]],
                            @[@[@1, @"이용 약관"], @[@1, @"개인정보 취급방침"], @[@1, @"이용 문의", @"c92921@gmail.com"], @[@0, @"버전", @"0.1"], @[@0, @"빌드 번호", @"1"]],
                            @[@[@2, @"계정 삭제"]]
                        ]];
    
    UITableView *settingTableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    self.settingTableView = settingTableView;
    settingTableView.delegate = self;
    settingTableView.dataSource = self;
    
    [self.view addSubview:settingTableView];
    
}

// UITableViewDataSource Methods -------------------------------//
#pragma mark - Section Header Settings

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [(NSArray *)self.settingArr[0] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return (NSString *)self.settingArr[0][section];
}


// UITableViewDataSource Methods -------------------------------//
#pragma mark - Rows Settings

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [(NSArray *)self.settingArr[1][section] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.textLabel.text = (NSString *)self.settingArr[1][indexPath.section][indexPath.row][1];
    
    switch ([(NSNumber *)self.settingArr[1][indexPath.section][indexPath.row][0] integerValue]) {
        case 0:
            cell.accessoryType = UITableViewCellAccessoryNone ;
            break;
            
        case 1:
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;

        default:
            cell.accessoryType = UITableViewCellAccessoryNone;
            [cell.textLabel setTextColor:[UIColor redColor]];
            [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
            break;
    }
    
    // accessory 추가 Label
    if ([self.settingArr[1][indexPath.section][indexPath.row] count] == 3) {
        NSLog(@"추가 accessibilityLabel");
        cell.accessoryView.accessibilityLabel = self.settingArr[1][indexPath.section][indexPath.row][2];
    }
    
    return cell;
}


@end
