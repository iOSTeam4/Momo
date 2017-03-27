//
//  MainTabBarController.m
//  Momo
//
//  Created by Jeheon Choi on 2017. 3. 27..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import "MainTabBarController.h"
#import "DataCenter.h"

static NSString * const LAUNCH_SEGUE = @"LaunchViewSegue";


@interface MainTabBarController ()

@end

@implementation MainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)autoLoginCheck {
    
    NSLog(@"autoLoginCheck");
    
    if (![DataCenter getUserToken]) {
        // Token이 없으면 nil
        
        NSLog(@"토큰 정보 없음, Login View로 이동");
        [self performSegueWithIdentifier:LAUNCH_SEGUE sender:self];
    }
}


@end
