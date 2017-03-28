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




// TabBarController Setting -----------------------------------//

- (void)setViewControllersWithTabBarItems {
    
    
    // get ViewControllers
    
    // 메인 뷰
    UINavigationController *mainNaviVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MainNaviViewController"];
    
    
    // 지도 뷰
    UIStoryboard *mapStoryBoard = [UIStoryboard storyboardWithName:@"MapView" bundle:nil];
    UINavigationController *mapNaviVC = [mapStoryBoard instantiateViewControllerWithIdentifier:@"MapNaviViewController"];
    
    // set ViewControllers
    [self setViewControllers:@[mainNaviVC, mapNaviVC]];

    
    
    // set TabBarItems
    UITabBarItem *item1 = [[UITabBarItem alloc] initWithTitle:@"메인" image:nil tag:100];
    UITabBarItem *item2 = [[UITabBarItem alloc] initWithTitle:@"지도" image:nil tag:200];
    
    mainNaviVC.tabBarItem = item1;
    mapNaviVC.tabBarItem = item2;
    
}




@end
