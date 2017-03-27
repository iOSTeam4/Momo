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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.navigationController.navigationBar setHidden:YES];
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

@end
