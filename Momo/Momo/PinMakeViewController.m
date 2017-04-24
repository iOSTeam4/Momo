//
//  PinMakeViewController.m
//  Momo
//
//  Created by Hanson Jung on 2017. 4. 4..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import "PinMakeViewController.h"
#import "MapViewController.h"
#import "PinViewController.h"

@interface PinMakeViewController () <UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (nonatomic) CGFloat lat;
@property (nonatomic) CGFloat lng;

@property (nonatomic) BOOL isEditMode;
@property (nonatomic) MomoPinDataSet *pinData;

@property (nonatomic) BOOL wasSelectedMapView;
@property (nonatomic) NSInteger selectedMapPK;

@property (weak, nonatomic) IBOutlet UILabel *viewTitleLabel;

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIButton *mapCheckRefOriginY;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *segmentedTopMargin;
@property (weak, nonatomic) IBOutlet UITextField *pinNameTextField;

@property (weak, nonatomic) IBOutlet UIButton *categoryCafeBtn;
@property (weak, nonatomic) IBOutlet UIButton *categoryFoodBtn;
@property (weak, nonatomic) IBOutlet UIButton *categoryShopBtn;
@property (weak, nonatomic) IBOutlet UIButton *categoryPlaceBtn;
@property (weak, nonatomic) IBOutlet UIButton *categoryEtcBtn;

@property (weak, nonatomic) UIButton *categoryLastSelectedBtn;
@property (weak, nonatomic) UIButton *mapLastSelectedBtn;
@property (nonatomic) UIButton *deleteBtn;
@property (nonatomic) NSMutableArray<UIButton *> *mapCheckBtnArr;

@property (nonatomic) BOOL checkName;
@property (nonatomic) BOOL checkCategory;
@property (nonatomic) BOOL checkMap;
@property (weak, nonatomic) IBOutlet UIButton *makeBtn1;
@property (weak, nonatomic) IBOutlet UIButton *makeBtn2;
@property (weak, nonatomic) IBOutlet UIButton *makeBtn3;

@property (weak, nonatomic) UIActivityIndicatorView *indicator;

@end

@implementation PinMakeViewController

// 미리 핀의 위도, 경도 값 세팅하는 메서드
- (void)setLat:(CGFloat)lat
       withLng:(CGFloat)lng {
    self.lat = lat;
    self.lng = lng;
}

// 수정할 때, 미리 부르는 메서드
- (void)setEditModeWithPinData:(MomoPinDataSet *)pinData {
    self.pinData = pinData;
    self.isEditMode = YES;
}


// 선택 지도보기에서 핀 생성으로 이동했을 때
- (void)wasSelectedMap:(BOOL)wasSelectedMapView
             withMapPK:(NSInteger)selectedMap_pk {

    self.wasSelectedMapView = wasSelectedMapView;
    self.selectedMapPK = selectedMap_pk;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    // 스토리보드로 옮길 것 --------------------//
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.center = self.view.center;
    indicator.hidesWhenStopped = YES;
    [self.view addSubview:indicator];
    self.indicator = indicator;
    //------------------------------------//
    
    // pinNameTextField에 셀렉터 추가
    [self.pinNameTextField addTarget:self action:@selector(textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
    
    // 지도 데이터 설정
    [self makeMyMapCheckBtnViewWithArr:[DataCenter myMapList]];
    
    // category button shadow
    for (UIButton *labelBtn in @[self.categoryCafeBtn, self.categoryFoodBtn, self.categoryShopBtn, self.categoryPlaceBtn, self.categoryEtcBtn]) {
        labelBtn.layer.shadowOffset = CGSizeMake(0, 7);
        labelBtn.layer.shadowRadius = 8;
        labelBtn.layer.shadowOpacity = 0.2;
    }
    
    
    // EditMode
    if (self.isEditMode) {
        NSLog(@"PinMakeViewController isEditMode");
        
        [self.view layoutIfNeeded];     // viewDidLoad에서 View Layout 맞추기 (삭제버튼 위치)
        
        // 수정 버튼 활성화
        self.checkName = YES;
        self.checkCategory = YES;
        self.checkMap = YES;
        
        
        // Edit 모드에 맞게 수정
        self.viewTitleLabel.text = @"핀 수정하기";
        [self.makeBtn2 setTitle:@"수정하기" forState:UIControlStateNormal];


        // 삭제 버튼 추가
        self.deleteBtn = [[UIButton alloc] init];
        [self.deleteBtn setFrame:CGRectMake(self.makeBtn3.frame.origin.x+3, self.makeBtn3.frame.origin.y+70, 34, 44)];
        [self.deleteBtn setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
        [self.contentView addSubview:self.deleteBtn];
        [self.deleteBtn addTarget:self action:@selector(selectedDeletePinBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        
        // 기존 핀 정보 넣기
        self.pinNameTextField.text = self.pinData.pin_name;     // 핀 이름
    
        switch (self.pinData.pin_label) {               // 카테고리(라벨) 정보
            case 0:
                [self selecedCategoryBtn:self.categoryCafeBtn];
                break;
            case 1:
                [self selecedCategoryBtn:self.categoryFoodBtn];
                break;
            case 2:
                [self selecedCategoryBtn:self.categoryShopBtn];
                break;
            case 3:
                [self selecedCategoryBtn:self.categoryPlaceBtn];
                break;
            default:
                [self selecedCategoryBtn:self.categoryEtcBtn];
                break;
        }
    }
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
        
}


- (void)makeMyMapCheckBtnViewWithArr:(RLMArray<MomoMapDataSet *> *)mapArr {
    
    self.mapCheckBtnArr = [[NSMutableArray alloc] init];
    
    CGFloat offsetY = self.mapCheckRefOriginY.frame.origin.y;
    
    for (NSInteger i =0 ; i < mapArr.count ; i++) {
        UIView *btnView = [[UIView alloc] initWithFrame:CGRectMake(26, offsetY, self.view.frame.size.width-52, 29)];
        [self.contentView addSubview:btnView];
        
        UIButton *mapCheckBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [mapCheckBtn setImage:[UIImage imageNamed:@"mapCheckBtn"] forState:UIControlStateNormal];
        [mapCheckBtn setImage:[UIImage imageNamed:@"mapSelectButton"] forState:UIControlStateSelected];
        [mapCheckBtn setContentMode:UIViewContentModeScaleAspectFit];
        
        UIButton *mapNameBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [mapNameBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [mapNameBtn setTitle:mapArr[i].map_name forState:UIControlStateNormal];
        [mapNameBtn setTitleColor:[UIColor colorWithRed:84/255.0 green:182/255.0 blue:249/255.0 alpha:1.0] forState:UIControlStateNormal];
        [mapNameBtn.titleLabel setFont:[UIFont systemFontOfSize:20]];
        [mapNameBtn.titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        
        mapCheckBtn.tag = i;
        mapNameBtn.tag = i;
        [self.mapCheckBtnArr addObject:mapCheckBtn];
        
        
        [mapCheckBtn addTarget:self action:@selector(selectedMapCheckBtn:) forControlEvents:UIControlEventTouchUpInside];
        [mapNameBtn addTarget:self action:@selector(selectedMapCheckBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        // 자물쇠가 있을 경우
        if (mapArr[i].map_is_private) {
            [mapNameBtn setImage:[UIImage imageNamed:@"lockBtnClose"] forState:UIControlStateNormal];
            [mapNameBtn setContentMode:UIViewContentModeScaleAspectFit];
            [mapNameBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
            [mapNameBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
        
        } else {
            [mapNameBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 36, 0, 0)];
        }
        
        [btnView addSubview:mapCheckBtn];
        mapCheckBtn.frame = CGRectMake(0, 0, 29, 29);
        
        [btnView addSubview:mapNameBtn];
        CGSize mapNameTitleSize = [mapNameBtn.currentTitle sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20]}];
        CGFloat mapNameBtnWidth = mapNameTitleSize.width + 36;
        CGFloat mapNameBtnWidthMax = btnView.frame.size.width - (mapCheckBtn.frame.size.width + 1);
        
        if (mapNameBtnWidth > mapNameBtnWidthMax) {         // 지도명이 너무 길 때
            mapNameBtn.frame = CGRectMake(30, 0, mapNameBtnWidthMax, 29);
        } else {
            mapNameBtn.frame = CGRectMake(30, 0, mapNameBtnWidth, 29);
        }
        
        offsetY += 44;
        
        // 선택지도 보기에서 핀 만들기 들어왔을 때 (선택지도 미리 체킹되어 있게)
        if (self.wasSelectedMapView) {
            NSInteger mapIndex = [[DataCenter myMapList] indexOfObject:[DataCenter findMapDataWithMapPK:self.selectedMapPK]];
            
            if (mapCheckBtn.tag == mapIndex) {
                mapCheckBtn.selected = YES;
                self.mapLastSelectedBtn = mapCheckBtn;
                self.checkMap = YES;
            }
        }
        
        // 수정모드일 때, 등록되어있던 맵 정보 세팅 (map pk값으로 구별)
        if (self.isEditMode && (mapArr[i].pk == self.pinData.pin_map_pk)) {
            [self selectedMapCheckBtn:mapCheckBtn];
        }
    }
    
    // constraint의 property를 정의해서 맵이 늘어날수록 constraint가 대응하도록 한다
    self.segmentedTopMargin.constant = 30 + 44 * (mapArr.count - 1);
    // 변동 constraint를 준 후 반드시 명령
    [self.view layoutIfNeeded];
}



// Back Btn Action
- (IBAction)selectedPopViewBtn:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.pinNameTextField resignFirstResponder];
    
    return YES;
}

- (void)textFieldEditingChanged:(UITextField *)sender {
    
    if ([sender.text isEqualToString:@""]) {
        self.checkName = NO;
    } else {
        self.checkName = (BOOL)sender.text;
    }
    
    [self checkMakeBtnState];
}

- (IBAction)textFieldResignTapGesture:(id)sender {
    
    [self.pinNameTextField resignFirstResponder];
}




- (IBAction)selecedCategoryBtn:(UIButton *)sender {
    NSLog(@"%ld", sender.tag);
    
    // Radio Button
    if (sender == self.categoryLastSelectedBtn) {
        self.categoryLastSelectedBtn.selected = !self.categoryLastSelectedBtn.selected;
        
    } else {
        self.categoryLastSelectedBtn.selected = NO;
        self.categoryLastSelectedBtn.layer.shadowOpacity = 0.2;
        self.categoryLastSelectedBtn = sender;
        sender.selected = YES;
    }
    
    if (self.categoryLastSelectedBtn.selected) {
        self.categoryLastSelectedBtn.layer.shadowOpacity = 0;
    } else {
        self.categoryLastSelectedBtn.layer.shadowOpacity = 0.2;
    }
    
    self.checkCategory = self.categoryLastSelectedBtn.selected ? YES : NO;
    [self checkMakeBtnState];
}


- (void)selectedMapCheckBtn:(UIButton *)sender {
    NSLog(@"selectedMapCheckBtn %ld", sender.tag);

    if (self.mapCheckBtnArr[sender.tag] == self.mapLastSelectedBtn) {
        self.mapLastSelectedBtn.selected = !self.mapLastSelectedBtn.selected;
        
    } else {
        // 라스트버튼값은 초기화
        self.mapLastSelectedBtn.selected = NO;
        // 해당 누른버튼을 라스트버튼으로
        self.mapLastSelectedBtn = self.mapCheckBtnArr[sender.tag];
        // 누르면 해당 누른버튼 yes
        self.mapCheckBtnArr[sender.tag].selected = YES;
    }
    
    // 한개의 맵 체크했을 때 만들기 활성화. 삼항연산자 참이면 앞에꺼
    self.checkMap = self.mapCheckBtnArr[sender.tag].selected ? YES : NO;

    [self checkMakeBtnState];
    
}


- (void)checkMakeBtnState {
    if (self.checkName && self.checkCategory && self.checkMap) {
        for (UIButton *btn in @[self.makeBtn1, self.makeBtn2, self.makeBtn3]) [btn setEnabled:YES];
    } else {
        for (UIButton *btn in @[self.makeBtn1, self.makeBtn2, self.makeBtn3]) [btn setEnabled:NO];
    }
}


// Make Btn Action
- (IBAction)selectedMakeBtn {
    
    // 키보드 내리기
    [self.pinNameTextField resignFirstResponder];

    [self.indicator startAnimating];
    
    if (!self.isEditMode) {     // 만들기
        NSLog(@"새 핀 만들어!");
        
        [NetworkModule createPinRequestWithPinname:self.pinNameTextField.text
                                         withMapPK:[DataCenter myMapList][self.mapLastSelectedBtn.tag].pk
                                         withLabel:self.categoryLastSelectedBtn.tag
                                           withLat:self.lat
                                           withLng:self.lng
                                   withDescription:@"추후 생길 필드값입니다."
                               withCompletionBlock:^(BOOL isSuccess, NSString *result) {
                                   
                                   [self.indicator stopAnimating];
                                   
                                   if (isSuccess) {
                                       
                                       self.pinData = [[DataCenter myMapList][self.mapLastSelectedBtn.tag].map_pin_list lastObject];      // 새로 생성된 데이터가 lastObject
                                       [self showPinView];

                                   } else {
                                       [UtilityCenter presentCommonAlertController:self withMessage:result];
                                   }
                               }];
        
        
        

        
    } else {    // 수정하기
        NSLog(@"핀 수정해!");
        
        [NetworkModule updatePinRequestWithPinPK:self.pinData.pk
                                     withPinname:self.pinNameTextField.text
                                       withLabel:self.categoryLastSelectedBtn.tag
                                       withMapPK:self.pinData.pin_map_pk
                             withCompletionBlock:^(BOOL isSuccess, NSString *result) {
                                 
                                 [self.indicator stopAnimating];
                                 
                                 if (isSuccess) {
                                     
                                     // 핀 뷰에서 수정했을 때
                                     if (self.wasPinView) {
                                         [self dismissViewControllerAnimated:YES completion:nil];
                                     } else {
                                         [self showPinView];    // 수정된 핀 뷰로 이동
                                     }
                                     
                                 } else {
                                     [UtilityCenter presentCommonAlertController:self withMessage:result];
                                 }
                                 
                                 
                             }];
        
        
//        RLMRealm *realm = [RLMRealm defaultRealm];
//        [realm transactionWithBlock:^{
//            self.pinData.pin_name = self.pinNameTextField.text;
//            self.pinData.pin_label = self.categoryLastSelectedBtn.tag;
//
//            
//            // 선택한 맵에 핀 새로 등록
//            [[DataCenter myMapList][self.mapLastSelectedBtn.tag].map_pin_list addObject:self.pinData];
//
//            // 기존 맵에 핀 삭제
//            NSInteger pinIndex = [self.pinData.pin_map.map_pin_list indexOfObject:self.pinData];
//            [self.pinData.pin_map.map_pin_list removeObjectAtIndex:pinIndex];
//            
//            // 핀 속에 지도 정보 변경
//            self.pinData.pin_map = [DataCenter myMapList][self.mapLastSelectedBtn.tag];
//            
//        }];
    }
}

- (void)showPinView {
    UIStoryboard *pinStoryBoard = [UIStoryboard storyboardWithName:@"PinView" bundle:nil];
    PinViewController *pinVC = [pinStoryBoard instantiateInitialViewController];
    
    // 핀뷰 이동 전, 데이터 세팅
    [pinVC showSelectedPinAndSetPinData:self.pinData];

    // 이전 MapView에서 만들기 모드 해제 (네비 구조이므로)
    [((MapViewController *)((UINavigationController *)((MainTabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController).selectedViewController).topViewController) successCreatePin];
      

    // 만들어진 핀으로 먼저 Push
    [((UINavigationController *)((MainTabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController).selectedViewController) pushViewController:pinVC animated:NO];

    [self dismissViewControllerAnimated:YES completion:nil];
}



// Delete Btn Action
- (void)selectedDeletePinBtn:(id)sender {
    NSLog(@"핀 지워");
    
    // 키보드 내리기
    [self.pinNameTextField resignFirstResponder];

    
    [self.indicator startAnimating];
    
    [NetworkModule deletePinRequestWithPinData:self.pinData
                           withCompletionBlock:^(BOOL isSuccess, NSString *result) {
                               
                               [self.indicator stopAnimating];
                               
                               if (isSuccess) {
                                   [((UINavigationController *)((MainTabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController).selectedViewController) popToRootViewControllerAnimated:NO];   // 탭바 루트뷰까지 먼저 이동 (삭제된 핀 뷰로 다시 돌아가면 안되므로)
                                   [self dismissViewControllerAnimated:YES completion:nil];
                                   
                               } else {
                                   [UtilityCenter presentCommonAlertController:self withMessage:result];
                               }
                           }];
    
}

@end
