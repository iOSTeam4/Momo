//
//  SignupPageViewController.m
//  Momo
//
//  Created by Hanson Jung on 2017. 3. 28..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import "SignupPageViewController.h"
#import "LoginViewController.h"

@interface SignupPageViewController ()
<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *idTextField;
@property (weak, nonatomic) IBOutlet UITextField *pwTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;

@property (weak, nonatomic) UITextField *lastFirstResponderTextField;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@property (weak, nonatomic) IBOutlet UIButton *registerBtn;
@property (weak, nonatomic) IBOutlet UIButton *fbBtn;

@end


@implementation SignupPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.registerBtn.layer.cornerRadius = self.registerBtn.frame.size.height/2;
    self.fbBtn.layer.cornerRadius = self.fbBtn.frame.size.height/2;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [GoogleAnalyticsModule startGoogleAnalyticsTrackingWithScreenName:@"SignupPageViewController"];
    
    // 키보드 노티 설정
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardNoti:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardNoti:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // 키보드 노티 해제
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


// TextField, 키보드 처리 ----------------------------//

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField.tag == 1) {
        [self.pwTextField becomeFirstResponder];
        
    } else if (textField.tag == 2){
        [self.emailTextField becomeFirstResponder];
        
    } else {
        [self.emailTextField resignFirstResponder];
        
        // id, pw, email 셋 다 입력사항 있을 때, 회원가입 시도
        if (self.idTextField.text && self.pwTextField.text && self.emailTextField.text) {
            [self signupBtnAction:self.registerBtn];
        }
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    NSLog(@"textFieldDidBeginEditing");
    self.lastFirstResponderTextField = textField;
    //4개의 텍스트필드중 두번째걸 작성하고 있다면 그게 마지막 텍스트필드.
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    NSLog(@"touchesBegan");
    UITouch *touch = [[event allTouches] anyObject];
    if ([self.lastFirstResponderTextField isFirstResponder] && ([touch view] != self.lastFirstResponderTextField)) {
        //늘 내가 작성중인 텍스트필드가 마지막이라 바깥 어딜 눌러도 키보드가 내려간다.
        [self.lastFirstResponderTextField resignFirstResponder];
    }
}


// 키보드 노티 처리
- (void)keyboardNoti:(NSNotification *)keyboardNoti {
    NSLog(@"keyboardNoti : %@", keyboardNoti.name);
    
    CGSize kbSize = [keyboardNoti.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    // 회원가입 버튼이 기준점
    CGFloat registerBtnY = self.registerBtn.superview.frame.origin.y + self.registerBtn.frame.origin.y + self.registerBtn.frame.size.height + 5.0f;
    
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    
    
    if (aRect.size.height < registerBtnY) {
        // 키보드 노티에 따라 View 위 아래로 움직임
        if([keyboardNoti.name isEqualToString:@"UIKeyboardWillShowNotification"]) {
            
            CGFloat moveY = registerBtnY - aRect.size.height;
            self.view.frame = CGRectMake(0, -moveY, self.view.frame.size.width, self.view.frame.size.height);
            
        } else if([keyboardNoti.name isEqualToString:@"UIKeyboardWillHideNotification"]) {
            self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        }
    }
}




// Button Action ---------------------------------//

// 뒤로가기 버튼
- (IBAction)backBtnAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

// 회원가입 버튼
- (IBAction)signupBtnAction:(id)sender {
    
    [self.indicator startAnimating];
    [self.lastFirstResponderTextField resignFirstResponder];
    
    [NetworkModule signUpRequestWithUsername:self.idTextField.text
                                withPassword:self.pwTextField.text
                                   withEmail:self.emailTextField.text
                         withCompletionBlock:^(BOOL isSuccess, NSString* result) {
                             
                             [self.indicator stopAnimating];
                            
                             if (isSuccess) {
                                 NSLog(@"sign up success : %@", result);
                                 
                                 UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"회원가입 완료"
                                                                                                          message:result
                                                                                                   preferredStyle:UIAlertControllerStyleAlert];
                                 
                                 UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"확인"
                                                                                    style:UIAlertActionStyleDefault
                                                                                  handler:^(UIAlertAction * _Nonnull action) {

                                                                                      // 로그인뷰 페이지로 이동
                                                                                      [self.navigationController popToRootViewControllerAnimated:YES];
                                                                                  }];
                                 [alertController addAction:okButton];
                                 [self presentViewController:alertController animated:YES completion:nil];
 
                                 
                             } else {
                                 NSLog(@"error : %@", result);
                                 [UtilityCenter presentCommonAlertController:self withMessage:result];
                             }
                         }];
    
}


// 페북 버튼
- (IBAction)fbBtnAction:(id)sender {
    
    [self.indicator startAnimating];
    
    [FacebookModule fbLoginFromVC:self
              withCompletionBlock:^(BOOL isSuccess, NSString *token) {
                  
                  if (isSuccess) {
                      NSLog(@"fb 로그인 성공");
                    
                      [DataCenter initialSaveMomoUserData];  // 초기 DB 세팅
                      
                      [NetworkModule getMemberProfileRequestWithCompletionBlock:^(BOOL isSuccess, NSString *result) {

                          [self.indicator stopAnimating];
                          
                          if (isSuccess) {
                              NSLog(@"get Member Profile success : %@", result);
                              
                              // 로그인 체킹
                              [LoginViewController autoLoginCheck];
                              
                          } else {
                              NSLog(@"error : %@", result);
                              [UtilityCenter presentCommonAlertController:self withMessage:result];
                          }

                      }];
                      
                  } else {
                      [self.indicator stopAnimating];
                      NSLog(@"fb 로그인 실패");
                  }
              }];

}


@end
