//
//  PinMakeViewController.m
//  Momo
//
//  Created by Hanson Jung on 2017. 4. 4..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import "PinMakeViewController.h"
#import "PinViewController.h"

@interface PinMakeViewController () <UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (nonatomic) BOOL isEditMode;
@property (nonatomic) MomoPinDataSet *pinData;

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

@end

@implementation PinMakeViewController

- (void)setEditModeWithPinData:(MomoPinDataSet *)pinData {
    self.pinData = pinData;
    self.isEditMode = YES;
    NSLog(@"setEditModeWithPinData : pinData주소 %@", pinData);
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Navi Pop Gesture 활성화
    [self.navigationController.interactivePopGestureRecognizer setDelegate:self];

    // pinNameTextField에 셀렉터 추가
    [self.pinNameTextField addTarget:self action:@selector(textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
    
    // 지도 데이터 설정
    [self makeMyMapCheckBtnViewWithArr:[DataCenter myMapList]];
    
    // category button shadow
    self.categoryCafeBtn.layer.shadowOffset = CGSizeMake(0, 7);
    self.categoryCafeBtn.layer.shadowRadius = 8;
    self.categoryCafeBtn.layer.shadowOpacity = 0.2;
    self.categoryFoodBtn.layer.shadowOffset = CGSizeMake(0, 7);
    self.categoryFoodBtn.layer.shadowRadius = 8;
    self.categoryFoodBtn.layer.shadowOpacity = 0.2;
    self.categoryShopBtn.layer.shadowOffset = CGSizeMake(0, 7);
    self.categoryShopBtn.layer.shadowRadius = 8;
    self.categoryShopBtn.layer.shadowOpacity = 0.2;
    self.categoryPlaceBtn.layer.shadowOffset = CGSizeMake(0, 7);
    self.categoryPlaceBtn.layer.shadowRadius = 8;
    self.categoryPlaceBtn.layer.shadowOpacity = 0.2;
    self.categoryEtcBtn.layer.shadowOffset = CGSizeMake(0, 7);
    self.categoryEtcBtn.layer.shadowRadius = 8;
    self.categoryEtcBtn.layer.shadowOpacity = 0.2;
   
    
    
    
    
    
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
        UIView *btnView = [[UIView alloc] initWithFrame:CGRectMake(26, offsetY, self.view.frame.size.width-26, 29)];
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
        mapNameBtn.frame = CGRectMake(30, 0, btnView.frame.size.width - 40, 29);
        
        offsetY += 44;
        
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
    //Navigation없애고 커스텀 버튼으로 POP
    [self.navigationController popViewControllerAnimated:YES];
    
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
        [self.makeBtn1 setEnabled:YES];
        [self.makeBtn2 setEnabled:YES];
        [self.makeBtn3 setEnabled:YES];
    } else {
        [self.makeBtn1 setEnabled:NO];
        [self.makeBtn2 setEnabled:NO];
        [self.makeBtn3 setEnabled:NO];
    }
}


// Make Btn Action
- (IBAction)selectedMakeBtn {
    
    if (!self.isEditMode) {     // 만들기
        NSLog(@"새 핀 만들어!");
        
        self.pinData = [MomoPinDataSet makePinWithName:self.pinNameTextField.text
                                          withPinLabel:self.categoryLastSelectedBtn.tag
                                               withMap:self.mapLastSelectedBtn.tag];
        
    } else {    // 수정하기
        
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm transactionWithBlock:^{
            self.pinData.pin_name = self.pinNameTextField.text;
            self.pinData.pin_label = self.categoryLastSelectedBtn.tag;

            
            // 선택한 맵에 핀 새로 등록
            [[DataCenter myMapList][self.mapLastSelectedBtn.tag].map_pin_list addObject:self.pinData];

//            // 기존 맵에 핀 삭제
//            NSInteger pinIndex = [self.pinData.pin_map.map_pin_list indexOfObject:self.pinData];
//            [self.pinData.pin_map.map_pin_list removeObjectAtIndex:pinIndex];
//            
//            // 핀 속에 지도 정보 변경
//            self.pinData.pin_map = [DataCenter myMapList][self.mapLastSelectedBtn.tag];
            
        }];
    }
    
    UIStoryboard *pinStoryBoard = [UIStoryboard storyboardWithName:@"PinView" bundle:nil];
    PinViewController *pinVC = [pinStoryBoard instantiateInitialViewController];
//    [pinVC showSelectedPinAndSetMapData:self.pinData.pin_map withPinIndex:[self.pinData.pin_map.map_pin_list indexOfObject:self.pinData]];
    
    [self.navigationController pushViewController:pinVC animated:YES];
}


// Delete Btn Action
- (void)selectedDeletePinBtn:(id)sender {
    NSLog(@"핀 지워");
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
        [realm deleteObject:self.pinData];
    }];
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
