//
//  MapMakeViewController.m
//  Momo
//
//  Created by Hanson Jung on 2017. 4. 6..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import "MapMakeViewController.h"
#import "MapViewController.h"

@interface MapMakeViewController ()
<UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (nonatomic) BOOL isEditMode;
@property (nonatomic) MomoMapDataSet *mapData;

@property (weak, nonatomic) IBOutlet UILabel *viewTitleLabel;

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *mapNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *mapContentTextField;

@property (nonatomic) BOOL checkName;

@property (weak, nonatomic) IBOutlet UIButton *makeBtn1;
@property (weak, nonatomic) IBOutlet UIButton *makeBtn2;
@property (weak, nonatomic) IBOutlet UIButton *makeBtn3;
@property (weak, nonatomic) IBOutlet UISwitch *secretSwitch;
@property (nonatomic) UIButton *deleteBtn;

@end

@implementation MapMakeViewController

// 수정할 때, 미리 부르는 메서드
- (void)setEditModeWithMapData:(MomoMapDataSet *)mapData {
    self.mapData = mapData;
    self.isEditMode = YES;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // 맵 이름 텍스트필드 셀렉터 추가
    [self.mapNameTextField addTarget:self action:@selector(mapNameTextFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
    
    // EditMode
    if (self.isEditMode) {
        [self.view layoutIfNeeded];     // viewDidLoad에서 View Layout 맞추기 (삭제버튼 위치)
        
        // 버튼 활성화 상태로 놓음
        [self.makeBtn1 setEnabled:YES];
        [self.makeBtn2 setEnabled:YES];
        [self.makeBtn3 setEnabled:YES];
        
        // Edit 모드에 맞게 수정
        self.viewTitleLabel.text = @"맵 수정하기";
        [self.makeBtn2 setTitle:@"수정하기" forState:UIControlStateNormal];
        
        // 삭제 버튼 추가
        self.deleteBtn = [[UIButton alloc] init];
        [self.deleteBtn setFrame:CGRectMake(self.makeBtn3.frame.origin.x+3, self.makeBtn3.frame.origin.y+70, 34, 44)];
        [self.deleteBtn setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
        [self.contentView addSubview:self.deleteBtn];
        [self.deleteBtn addTarget:self action:@selector(selectedDeleteMapBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        // 기존 지도 정보 넣기
        self.mapNameTextField.text = self.mapData.map_name;
        self.mapContentTextField.text = self.mapData.map_description;
        self.secretSwitch.on = self.mapData.map_is_private;

    }
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [GoogleAnalyticsModule startGoogleAnalyticsTrackingWithScreenName:@"MapMakeViewController"];
}


// Back Btn Action
- (IBAction)selectedPopViewBtn:(id)sender {

    [self dismissViewControllerAnimated:YES completion:nil];
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
    
    if ([sender.text length] > 0) {
        self.checkName = YES;       // Text (YES)
    } else {
        self.checkName = NO;        // nil, @"" (NO)
    }
    
    [self checkMakeBtnState];
}


// 만들기버튼 활성화 메서드 -----------//
- (void)checkMakeBtnState {
    //모든 조건이 yes이면 makeBtn이 활성화되게
    if (self.checkName) {
        for (UIButton *btn in @[self.makeBtn1, self.makeBtn2, self.makeBtn3]) [btn setEnabled:YES];
    } else {
        for (UIButton *btn in @[self.makeBtn1, self.makeBtn2, self.makeBtn3]) [btn setEnabled:NO];
    }
}

- (IBAction)selectedMakeBtn:(id)sender {
    
    // 키보드 내리기
    for (UIView *view in @[self.mapNameTextField, self.mapContentTextField]) [view resignFirstResponder];
    
    [UtilityModule showIndicator];
    
    if (!self.isEditMode) {     // 만들기
        NSLog(@"새 맵 만들어!");

        [NetworkModule createMapRequestWithMapname:self.mapNameTextField.text
                                   withDescription:self.mapContentTextField.text
                                     withIsPrivate:self.secretSwitch.on
                               withCompletionBlock:^(BOOL isSuccess, NSString *result) {
                                   
                                   [UtilityModule dismissIndicator];
                                   
                                   if (isSuccess) {
                                       self.mapData = [[DataCenter myMapList] firstObject];      // 새로 생성된 데이터가 firstObject
                                       [self showMapView];
                                       
                                   } else {                                       
                                       [UtilityModule presentCommonAlertController:self withMessage:result];
                                   }
                                   
                               }];

    } else {    // 수정하기
        NSLog(@"맵 수정해!");
        
        [NetworkModule updateMapRequestWithMapPK:self.mapData.pk
                                     withMapname:self.mapNameTextField.text
                                 withDescription:self.mapContentTextField.text
                                   withIsPrivate:self.secretSwitch.on
                             withCompletionBlock:^(BOOL isSuccess, NSString *result) {
                                 
                                 [UtilityModule dismissIndicator];
                                 
                                 if (isSuccess) {
                                     
                                     // (선택지도) 맵 뷰에서 수정했을 때
                                     if (self.wasMapView) {
                                         [self dismissViewControllerAnimated:YES completion:nil];
                                     } else {
                                         [self showMapView];    // 수정된 맵 뷰로 이동
                                     }
                                     
                                 } else {
                                     [UtilityModule presentCommonAlertController:self withMessage:result];
                                 }
                                 
                             }];

    }
}

- (void)showMapView {
    UIStoryboard *mapStoryBoard = [UIStoryboard storyboardWithName:@"Map" bundle:nil];
    MapViewController *mapVC = [mapStoryBoard instantiateViewControllerWithIdentifier:@"MapViewController"];
    [mapVC showSelectedMapAndSetMapData:self.mapData];
    
    [((UINavigationController *)((MainTabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController).selectedViewController) pushViewController:mapVC animated:NO];        // 만들어진 맵으로 먼저 Push
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)selectedDeleteMapBtn:(id)sender {
    NSLog(@"맵 지워");
    
    // 키보드 내리기
    for (UIView *view in @[self.mapNameTextField, self.mapContentTextField]) [view resignFirstResponder];
    
    [UtilityModule showIndicator];
    
    [NetworkModule deleteMapRequestWithMapData:self.mapData
                           withCompletionBlock:^(BOOL isSuccess, NSString *result) {

                               [UtilityModule dismissIndicator];
                               
                               if (isSuccess) {
                                   
                                   [((MainTabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController) mainTabBarAnotherVCPopToRootViewController];   // Delete popToRootView처리
                                   
                                   [((UINavigationController *)((MainTabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController).selectedViewController) popToRootViewControllerAnimated:NO];   // 탭바 루트뷰까지 먼저 이동 (지워진 선택 지도 뷰로 다시 돌아가면 안되므로)
                                   [self dismissViewControllerAnimated:YES completion:nil];
                                   
                               } else {
                                   [UtilityModule presentCommonAlertController:self withMessage:result];
                               }
                           }];
    
}


@end
