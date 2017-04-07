//
//  LoginViewController.m
//  Momo
//
//  Created by Jeheon Choi on 2017. 3. 27..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController () <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoViewCenterYConstraint;     // 추후 시작할 때에, 이 NSLayoutConstraint로 로고뷰 위로 올리는 애니메이션 추가

@property (weak, nonatomic) IBOutlet UIButton *fbBtn;

@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIButton *signUpBtn;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Navi Pop Gesture 활성화
    [self.navigationController.interactivePopGestureRecognizer setDelegate:self];

    self.fbBtn.layer.cornerRadius = self.fbBtn.frame.size.height/2;
    self.loginBtn.layer.cornerRadius = self.loginBtn.frame.size.height/2;
    self.signUpBtn.layer.cornerRadius = self.signUpBtn.frame.size.height/2;

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [GoogleAnalyticsModule startGoogleAnalyticsTrackingWithScreenName:@"LoginViewController"];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self autoLoginCheck];
}



// Auto Login Check Method -----------------------------------//

- (void)autoLoginCheck {
    
    NSLog(@"autoLoginCheck");
    
    if ([DataCenter getUserToken]) {
        // Token이 없으면 nil : NO, 있으면 YES
        NSLog(@"Token : %@", [DataCenter getUserToken]);
        
        //        sleep(3);       // 3초 후 dismiss
//        [self dismissViewControllerAnimated:YES completion:nil];
        
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *mainTabBarController = [mainStoryboard instantiateInitialViewController];

        [[UIApplication sharedApplication].keyWindow setRootViewController:mainTabBarController];
        [[UIApplication sharedApplication].keyWindow makeKeyAndVisible];
        
    } else {
        NSLog(@"토큰 정보 없음, Login View로 이동");
    }
    
}


// Facebook Login BtnAction ----------------------------------//

- (IBAction)fbBtnAction:(id)sender {
    [self.indicator startAnimating];
    
    [NetworkModule FacebookLoginFromVC:self
                   WithCompletionBlock:^(BOOL isSuccess, NSString *token) {
                       
                      [self.indicator stopAnimating];
                       
                       if (isSuccess) {
                           NSLog(@"로그인 성공");
                           [self autoLoginCheck];
                       
                       } else {                           
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
                           
                       }
                   }];
}


@end
