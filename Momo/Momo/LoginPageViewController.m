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

@end

@implementation LoginPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.idTextField.delegate = self;
    self.pwTextField.delegate = self;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField.tag == 1) {
        [self.pwTextField becomeFirstResponder];
        
    } else {
        [self.pwTextField resignFirstResponder];
    }
    
    
    return YES;
    
}

- (IBAction)loginBtnAction:(id)sender {
    
    [NetworkModule loginRequestWithUsername:self.idTextField.text
                               withPassword:self.pwTextField.text
                        withCompletionBlock:^(BOOL isSuccess, NSDictionary *result) {
                            
                            if (isSuccess) {
                                
                                NSLog(@"log in success %@", result);
                                
                            } else {
                                
                                NSLog(@"system error %@", result);
                            }
                            
                        }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
