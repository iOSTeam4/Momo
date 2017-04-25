//
//  FollowViewController.m
//  Momo
//
//  Created by Jeheon Choi on 2017. 4. 17..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import "FollowViewController.h"


#pragma mark - FollowTableViewCell
// FollowTableViewCell -----------------------------//

@implementation FollowTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    NSLog(@"FollowTableViewCell awakeFromNib");
}

- (void)layoutSubviews {
    [super layoutSubviews];
    NSLog(@"FollowTableViewCell layoutSubviews");

    // BackView 세팅
//    [self.backView.layer setCornerRadius:10];
    self.backView.layer.shadowOffset = CGSizeMake(-5, 8);
    self.backView.layer.shadowRadius = 10;
    self.backView.layer.shadowOpacity = 0.3;
    

    // 프로필 사진 동그랗게
    [self.userImgView.layer setCornerRadius:self.userImgView.frame.size.height/2];
    NSLog(@"cell width : %f , userImgView.frame.size.height/2 : %f", self.frame.size.width, self.userImgView.frame.size.height/2);
    
    // 수정하기 버튼
    [self.followBtn.layer setCornerRadius:12];
    [self.followBtn.layer setBorderColor:[UIColor mm_brightSkyBlueColor].CGColor];
    [self.followBtn.layer setBorderWidth:1];
    
    self.followBtn.layer.shadowOffset = CGSizeMake(-5, 8);
    self.followBtn.layer.shadowRadius = 10;
    self.followBtn.layer.shadowOpacity = 0.3;
    
}

@end




#pragma mark - FollowViewController
// FollowViewController ----------------------------//

@interface FollowViewController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation FollowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}


// TableView Methods ----------------------------//

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FollowTableViewCell *followCell = [tableView dequeueReusableCellWithIdentifier:@"followCell" forIndexPath:indexPath];
    
    return followCell;
}

@end
