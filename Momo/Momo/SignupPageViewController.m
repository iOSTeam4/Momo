//
//  SignupPageViewController.m
//  Momo
//
//  Created by Hanson Jung on 2017. 3. 28..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import "SignupPageViewController.h"
#import "DataCenter.h"
#import "NetworkModule.h"

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
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField.tag == 1) {
        NSLog(@"textField.tag == 1");
        [self.pwTextField becomeFirstResponder];
    } else if (textField.tag == 2){
        [self.emailTextField becomeFirstResponder];
    } else {
        [self.emailTextField resignFirstResponder];
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


- (IBAction)signupBtnAction:(id)sender {
    
    [self.indicator startAnimating];
    //[self.indicatorView setHidden:NO];
    [self.lastFirstResponderTextField resignFirstResponder];
    
    [NetworkModule signUpRequestWithUsername:self.idTextField.text
                               withPassword1:self.pwTextField.text
                               withPassword2:self.pwTextField.text
                                   withEmail:self.emailTextField.text
                         withCompletionBlock:^(BOOL isSuccess, NSDictionary* result) {
                             
                             [self.indicator stopAnimating];
                            
                             if (isSuccess) {
                                 NSLog(@"log in success %@", result);
                                 [self.navigationController popToRootViewControllerAnimated:NO];
                                 
                                 
                             } else {
                                 NSLog(@"system error %@", result);
                                 
                                 UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"oops!"
                                                                                                          message:@"이미 존재하는 아이디입니다. 다시 해주세요."
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

- (IBAction)fbBtnAction:(id)sender {
    [self.indicator startAnimating];
    
    [NetworkModule FacebookLoginFromVC:self
                   WithCompletionBlock:^(BOOL isSuccess, NSString *token) {
                       
                       [self.indicator stopAnimating];
                       
                       if (isSuccess) {
                           NSLog(@"로그인 성공");
                           [self.navigationController popToRootViewControllerAnimated:NO];
                           
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
