//
//  MainViewController.m
//  Momo
//
//  Created by Jeheon Choi on 2017. 3. 27..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import "MainViewController.h"
#import "MainTabBarController.h"

@interface MainViewController ()

@end


@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationItem setTitle:@"Main View"];

    // ShowLoginView & AutoLoginCheck
    NSLog(@"performSegueWithIdentifier");
    [self performSegueWithIdentifier:LAUNCH_SEGUE sender:self];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




- (void)viewWillAppear:(BOOL)animated {

}

- (IBAction)logoutTempBtnAction:(id)sender {
    
    [DataCenter removeUserToken];
    [self performSegueWithIdentifier:LAUNCH_SEGUE sender:self];
}




@end


