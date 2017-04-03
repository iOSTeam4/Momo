//
//  LoginViewController.m
//  Momo
//
//  Created by Jeheon Choi on 2017. 3. 27..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UIButton *fbLoginBtn;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [GoogleAnalyticsModule startGoogleAnalyticsTrackingWithScreenName:@"LoginViewController"];
}


- (IBAction)fbBtnAction:(id)sender {
    
    [self.indicator startAnimating];
    
    [NetworkModule FacebookLoginFromVC:self
                   WithCompletionBlock:^(BOOL isSuccess, NSString *token) {
                       if (isSuccess) {
                           
                           dispatch_async(dispatch_get_main_queue(), ^{
                               
                               [self.indicator stopAnimating];
                               
                               NSLog(@"로그인 성공");
                               [self.navigationController popToRootViewControllerAnimated:NO];
                               
                           });
                       } else {
                           dispatch_async(dispatch_get_main_queue(), ^{
                               
                               [self.indicator stopAnimating];
                               
                               UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"oops!"
                                                                                                        message:@"로그인 실패하였습니다. 다시 해주세요."
                                                                                                 preferredStyle:UIAlertControllerStyleAlert];
                               
                               UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"확인"
                                                                                  style:UIAlertActionStyleDefault
                                                                                handler:^(UIAlertAction * _Nonnull action) {
                                                                                    NSLog(@"확인버튼이 클릭되었습니다");
                                                                                }];
                               [alertController addAction:okButton];
                               
                               [self presentViewController:alertController animated:YES completion:nil];
                               
                           });
                       }
                   }];    
}


@end
