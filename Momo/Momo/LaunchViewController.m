//
//  LaunchViewController.m
//  Momo
//
//  Created by Jeheon Choi on 2017. 3. 27..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import "LaunchViewController.h"

@interface LaunchViewController ()

@end

@implementation LaunchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setHidden:YES];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self autoLoginCheck];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// UIButtonAction : 버튼 액션 관련 -------------------------//

- (IBAction)loginBtnAction:(id)sender {
    
    [self.navigationController.navigationBar setHidden:NO];
    [self performSegueWithIdentifier:LOGIN_SEGUE sender:self];
    
}


- (IBAction)goMain_Temp:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


// Auto Login Check Method -----------------------------------//

- (void)autoLoginCheck {
    
    NSLog(@"autoLoginCheck");
    
    if ([DataCenter getUserToken]) {
        // Token이 없으면 nil : NO, 있으면 YES
        NSLog(@"Token : %@", [DataCenter getUserToken]);
    
//        sleep(3);       // 3초 후 dismiss
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }
    
    NSLog(@"토큰 정보 없음, Login View로 이동");
    
}


@end
