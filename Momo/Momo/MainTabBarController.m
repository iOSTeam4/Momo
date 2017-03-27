//
//  MainTabBarController.m
//  Momo
//
//  Created by Jeheon Choi on 2017. 3. 27..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import "MainTabBarController.h"

@interface MainTabBarController ()

@end

@implementation MainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setViewControllersWithTabBarItems];       // TabBarController Setting
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




// TabBarController Setting -----------------------------------//

- (void)setViewControllersWithTabBarItems {
    
    
    // get ViewControllers
    
    // 메인 뷰
    UINavigationController *mainNaviVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MainNaviViewController"];
    
    
    // 지도 뷰
    UIStoryboard *mapStoryBoard = [UIStoryboard storyboardWithName:@"Map" bundle:nil];
    UINavigationController *mapNaviVC = [mapStoryBoard instantiateViewControllerWithIdentifier:@"MapNaviViewController"];
    
    // set ViewControllers
    [self setViewControllers:@[mainNaviVC, mapNaviVC]];

    
    
    // set TabBarItems
    UITabBarItem *item1 = [[UITabBarItem alloc] initWithTitle:@"메인" image:nil tag:100];
    UITabBarItem *item2 = [[UITabBarItem alloc] initWithTitle:@"지도" image:nil tag:200];
    
    mainNaviVC.tabBarItem = item1;
    mapNaviVC.tabBarItem = item2;
    
}






// Auto Login Check Method -----------------------------------//

- (void)autoLoginCheck {
    
    NSLog(@"autoLoginCheck");
    
    if (![DataCenter getUserToken]) {
        // Token이 없으면 nil
        
        NSLog(@"토큰 정보 없음, Login View로 이동");
        [self performSegueWithIdentifier:LAUNCH_SEGUE sender:self];
    }
}


@end
