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

@property (weak, nonatomic) IBOutlet UIView *loginBtnView;
@property (weak, nonatomic) IBOutlet UIButton *fbBtn;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIButton *signUpBtn;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Navi Pop Gesture 활성화, 아래 gestureRecognizerShouldBegin와 세트
    [self.navigationController.interactivePopGestureRecognizer setDelegate:self];

    self.fbBtn.layer.cornerRadius = self.fbBtn.frame.size.height/2;
    self.loginBtn.layer.cornerRadius = self.loginBtn.frame.size.height/2;
    self.signUpBtn.layer.cornerRadius = self.signUpBtn.frame.size.height/2;

    
    // 앱 실행하면서, Realm에 있는 유저 정보 패치
    [self.indicator startAnimating];
    [[DataCenter sharedInstance] fetchMomoUserData];
    [self.indicator stopAnimating];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [GoogleAnalyticsModule startGoogleAnalyticsTrackingWithScreenName:@"LoginViewController"];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self autoLoginCheck];  // 자동 로그인 체크
}


// NaviBar Hidden 상황 & PopGestureRecognizer 사용 예외처리
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    
    // NaviController RootViewController에서는 PopGesture 실행 안되도록 처리 (다른 Gesture 쓰는 것 없음)
    if(self.navigationController.viewControllers.count > 1){
        return YES;
    }
    return NO;
}




// Auto Login Check Method -----------------------------------//

- (void)autoLoginCheck {
    
    NSLog(@"autoLoginCheck");
    
    if ([[DataCenter sharedInstance] getUserToken]) {
        // Token 있으면 YES, 없으면 nil(NO)
        NSLog(@"Token : %@", [[DataCenter sharedInstance] getUserToken]);
        

        // Momo Server - get User profile Infos
        NSLog(@"getMemberProfile");
        [self.indicator startAnimating];
        [NetworkModule getMemberProfileRequestWithCompletionBlock:^(BOOL isSuccess, NSString *result) {
            
            [self.indicator stopAnimating];
            
            if (isSuccess) {
                
                
                
            } else {
                
            }

        }];
        
//        sleep(3);       // 3초 후 dismiss
//        [self dismissViewControllerAnimated:YES completion:nil];
        
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Map" bundle:nil];
        UIViewController *mainTabBarController = [mainStoryboard instantiateInitialViewController];

        [[UIApplication sharedApplication].keyWindow setRootViewController:mainTabBarController];
        [[UIApplication sharedApplication].keyWindow makeKeyAndVisible];
        
    } else {
        NSLog(@"토큰 정보 없음");
    
    }
}


// Facebook Login BtnAction ----------------------------------//

- (IBAction)fbBtnAction:(id)sender {
    
    [self.indicator startAnimating];
    
    [FacebookModule fbLoginFromVC:self
              withCompletionBlock:^(BOOL isSuccess, NSString *token) {
                  
                  [self.indicator stopAnimating];
                  
                  if (isSuccess) {
                      NSLog(@"fb 로그인 성공");
                      
                      [DataCenter initialSaveMomoUserData];  // 초기 DB 세팅
                      
                      // 임시로 더미데이터 세팅 /////
                      [NetworkModule fetchUserMapData];
                      /////////////////////////
                      
                      
                      [self autoLoginCheck];
                      
                  } else {
                      NSLog(@"fb 로그인 실패");
                  }
              }];
}


@end
