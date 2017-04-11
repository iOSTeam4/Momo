//
//  MapMakeViewController.m
//  Momo
//
//  Created by Hanson Jung on 2017. 4. 6..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import "MapMakeViewController.h"

@interface MapMakeViewController ()
<UITextFieldDelegate>


@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *mapNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *mapContentTextField;

@property (nonatomic) BOOL checkName;
@property (nonatomic) BOOL checkContent;
@property (weak, nonatomic) IBOutlet UIButton *makeBtn1;
@property (weak, nonatomic) IBOutlet UIButton *makeBtn2;
@property (weak, nonatomic) IBOutlet UIButton *makeBtn3;
@property (weak, nonatomic) IBOutlet UISwitch *secretSwitch;

@end

@implementation MapMakeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:YES];
    
    [self.mapNameTextField addTarget:self action:@selector(mapNameTextFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.mapContentTextField addTarget:self action:@selector(mapContentTextFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    //NavigationBar 숨긴거 되살리기
    [self.navigationController setNavigationBarHidden:NO];
    
}

- (IBAction)selectedPopViewBtn:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField.tag == 1) {
        [self.mapContentTextField becomeFirstResponder];
        [self.scrollView setContentOffset:CGPointMake(0,200) animated:YES];
        
    } else {
        [self.mapContentTextField resignFirstResponder];
        [self.scrollView setContentOffset:CGPointMake(0,0) animated:YES];

    }
    return YES;
}

- (IBAction)textFieldResignTapGesture:(id)sender {
    [self.mapNameTextField resignFirstResponder];
    [self.mapContentTextField resignFirstResponder];
}


// 핀이름 textfield에 space 입력했을때를 걸러내려고 --------------//
- (void)mapNameTextFieldEditingChanged:(UITextField *)sender {
    
    if ([sender.text isEqualToString:@""]) {
        self.checkName = NO;
    } else {
        self.checkName = (BOOL)sender.text;
    }
    
    [self checkMakeBtnState];
}

- (void)mapContentTextFieldEditingChanged:(UITextField *)sender {
    
    if ([sender.text isEqualToString:@""]) {
        self.checkContent = NO;
    } else {
        self.checkContent = (BOOL)sender.text;
    }
    
    [self checkMakeBtnState];
}

// 만들기버튼 활성화 메서드 -----------//
- (void)checkMakeBtnState {
    //모든 조건이 yes이면 makeBtn이 활성화되게
    if (self.checkName && self.checkContent) {
        [self.makeBtn1 setEnabled:YES];
        [self.makeBtn2 setEnabled:YES];
        [self.makeBtn3 setEnabled:YES];
    } else {
        [self.makeBtn1 setEnabled:NO];
        [self.makeBtn2 setEnabled:NO];
        [self.makeBtn3 setEnabled:NO];
    }
}

- (IBAction)selectedMapMakeView:(id)sender {
    
    NSLog(@"새맵 만들어!");
//    [self.navigationController popViewControllerAnimated:YES];
    
    [self makeMapWithName:self.mapNameTextField.text
           withMapContent:self.mapContentTextField.text
              withPrivate:self.secretSwitch.on];
    
    [self.navigationController popViewControllerAnimated:YES];
    
}


- (IBAction)flickedSecretSwitch:(id)sender {
    NSLog(@"비밀지도 switch");
    
}

// 아마 데이터 센터에 추가 될 메서드 (일단 예시로 여기다 만들어놓음)
- (void)makeMapWithName:(NSString *)name
           withMapContent:(NSString *)content
            withPrivate:(BOOL)private {
    // 알아서 안에서 데이터 처리~~~
    
    NSLog(@"name : %@", name);
    NSLog(@"content : %@", content);
    NSLog(@"private : %d", private);
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
