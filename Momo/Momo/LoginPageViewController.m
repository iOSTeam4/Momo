//
//  LoginPageViewController.m
//  Momo
//
//  Created by Hanson Jung on 2017. 3. 27..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import "LoginPageViewController.h"
#import "NetworkModule.h"

@interface LoginPageViewController ()
<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *idTextField;
@property (weak, nonatomic) IBOutlet UITextField *pwTextField;
@property (weak, nonatomic) UITextField *lastFirstResponderTextField;

@property (weak, nonatomic) IBOutlet UIButton *signInBtn;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@end

@implementation LoginPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.signInBtn.layer.cornerRadius = self.signInBtn.frame.size.height/2;

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [GoogleAnalyticsModule startGoogleAnalyticsTrackingWithScreenName:@"LoginPageViewController"];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField.tag == 1) {
        [self.pwTextField becomeFirstResponder];
        
    } else {
        [self.pwTextField resignFirstResponder];
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

- (IBAction)loginBtnAction:(id)sender {
    
    [self.indicator startAnimating];
    [self.lastFirstResponderTextField resignFirstResponder];
    
    [NetworkModule loginRequestWithUsername:self.idTextField.text
                               withPassword:self.pwTextField.text
                        withCompletionBlock:^(BOOL isSuccess, NSDictionary *result) {
                            
                            [self.indicator stopAnimating];

                            if (isSuccess) {
                                NSLog(@"log in success %@", result);
                                
                                [self.indicator stopAnimating];
                                [self.navigationController popToRootViewControllerAnimated:NO];
                                
                            } else {
                                NSLog(@"system error %@", result);
                                
                                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"oops!"
                                                                                                         message:@"아이디 또는 비밀번호가 틀렸네요"
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
