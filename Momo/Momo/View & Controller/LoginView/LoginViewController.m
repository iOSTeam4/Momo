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

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Navi Pop Gesture 활성화, 아래 gestureRecognizerShouldBegin와 세트
    [self.navigationController.interactivePopGestureRecognizer setDelegate:self];

    // 버튼 cornerRadius
    self.fbBtn.layer.cornerRadius = self.fbBtn.frame.size.height/2;
    self.loginBtn.layer.cornerRadius = self.loginBtn.frame.size.height/2;
    self.signUpBtn.layer.cornerRadius = self.signUpBtn.frame.size.height/2;

    
    // 앱 실행하면서, Realm에 있는 유저 정보 확인
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];        // whiteColor로 적용, dismiss하면서 다시 기본 컬러인 mm_brightSkyBlueColor로 세팅 됨
    [UtilityModule showIndicator];
    [[DataCenter sharedInstance] checkUserDataWithCompletionBlock:^(BOOL isSuccess) {
        [UtilityModule dismissIndicator];
        if (isSuccess) {
            // 자동로그인
            [LoginViewController autoLoginCheck];
        } else {
            // 로그인 버튼 노출
            [self.loginBtnView setHidden:NO];
        }
    }];


}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [GoogleAnalyticsModule startGoogleAnalyticsTrackingWithScreenName:@"LoginViewController"];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}


// NaviBar Hidden 상황 & PopGestureRecognizer 사용 예외처리
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    
    // NaviController RootViewController에서는 PopGesture 실행 안되도록 처리
    if(self.navigationController.viewControllers.count > 1){
        return YES;
    }
    return NO;
}




// Auto Login Check Method -----------------------------------//

+ (void)autoLoginCheck {
    
    NSLog(@"autoLoginCheck");
    
    if ([[DataCenter sharedInstance] getUserToken]) {
        // Token 있으면 YES, 없으면 nil(NO)
        NSLog(@"Token : %@", [[DataCenter sharedInstance] getUserToken]);
        
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

    // whiteColor로 적용, dismiss하면서 다시 기본 컬러인 mm_brightSkyBlueColor로 세팅 됨
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    
    [[FacebookModule fbNetworkManager]
     fbLoginFromVC:self
     withCompletionBlock:^(BOOL isSuccess, NSString *token) {
         
         if (isSuccess) {
             NSLog(@"fb 로그인 성공");
             
             [[NetworkModule momoNetworkManager] getMemberProfileRequestWithCompletionBlock:^(BOOL isSuccess, NSString *result) {
                 
                 [UtilityModule dismissIndicator];
                 
                 if (isSuccess) {
                     NSLog(@"get Member Profile success : %@", result);
                     
                     // 로그인 체킹
                     [LoginViewController autoLoginCheck];
                     
                 } else {
                     NSLog(@"error : %@", result);
                     [UtilityModule presentCommonAlertController:self withMessage:result];
                 }
                 
             }];
             
         } else {
             [UtilityModule dismissIndicator];
             NSLog(@"fb 로그인 실패");
         }
     }];
}


@end
