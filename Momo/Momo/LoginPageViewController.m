//
//  LoginPageViewController.m
//  Momo
//
//  Created by Hanson Jung on 2017. 3. 27..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import "LoginPageViewController.h"
#import "LoginViewController.h"

@interface LoginPageViewController ()
<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *idTextField;
@property (weak, nonatomic) IBOutlet UITextField *pwTextField;
@property (weak, nonatomic) UITextField *lastFirstResponderTextField;

@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@end

@implementation LoginPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.loginBtn.layer.cornerRadius = self.loginBtn.frame.size.height/2;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [GoogleAnalyticsModule startGoogleAnalyticsTrackingWithScreenName:@"LoginPageViewController"];
    
    // 키보드 노티 설정 (회원가입 페이지 이동도 하므로, viewWillAppear에서 설정)
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
        
    } else {
        [self.pwTextField resignFirstResponder];

        // id, pw 둘 다 입력사항 있을 때, 로그인 시도
        if (self.idTextField.text && self.pwTextField.text) {
            [self loginBtnAction:self.loginBtn];
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
    
    // 로그인 버튼이 기준점
    CGFloat loginBtnY = self.loginBtn.superview.frame.origin.y + self.loginBtn.frame.origin.y + self.loginBtn.frame.size.height + 5.0f;
    
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    
    
    if (aRect.size.height < loginBtnY) {
        // 키보드 노티에 따라 View 위 아래로 움직임
        if([keyboardNoti.name isEqualToString:@"UIKeyboardWillShowNotification"]) {
            
            CGFloat moveY = loginBtnY - aRect.size.height;
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

// 로그인 버튼
- (IBAction)loginBtnAction:(id)sender {
    
    [self.indicator startAnimating];
    [self.lastFirstResponderTextField resignFirstResponder];
    
    [NetworkModule loginRequestWithUsername:self.idTextField.text
                               withPassword:self.pwTextField.text
                        withCompletionBlock:^(BOOL isSuccess, NSString *result) {
                            
                            if (isSuccess) {
                                NSLog(@"log in success : %@", result);
                                
                                [DataCenter initialSaveMomoUserData];  // 초기 DB 세팅
                                
//                                // 임시로 더미데이터 세팅 /////
//                                [NetworkModule fetchUserMapData];
//                                /////////////////////////
                                
                                [NetworkModule getMemberProfileRequestWithCompletionBlock:^(BOOL isSuccess, NSString *result) {

                                    [self.indicator stopAnimating];
                                    
                                    if (isSuccess) {
                                        NSLog(@"get Member Profile success : %@", result);

                                        // 로그인 체킹
                                        [LoginViewController autoLoginCheck];


                                    } else {
                                        NSLog(@"error : %@", result);
                                        
                                        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"oops!"
                                                                                                                 message:result
                                                                                                          preferredStyle:UIAlertControllerStyleAlert];
                                        
                                        UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"확인"
                                                                                           style:UIAlertActionStyleDefault
                                                                                         handler:nil];
                                        [alertController addAction:okButton];
                                        [self presentViewController:alertController animated:YES completion:nil];
                                    }
                                    
                                }];
                                
                            } else {
                                [self.indicator stopAnimating];

                                NSLog(@"error : %@", result);
                                
                                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"oops!"
                                                                                                         message:@"아이디 또는 비밀번호가 틀렸습니다"
                                                                                                  preferredStyle:UIAlertControllerStyleAlert];
                                
                                UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"확인"
                                                                                   style:UIAlertActionStyleDefault
                                                                                 handler:nil];
                                [alertController addAction:okButton];
                                [self presentViewController:alertController animated:YES completion:nil];
                                
                            }
                        }];
    
}


@end
