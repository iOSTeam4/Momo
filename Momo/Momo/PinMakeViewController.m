//
//  PinMakeViewController.m
//  Momo
//
//  Created by Hanson Jung on 2017. 4. 4..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import "PinMakeViewController.h"

@interface PinMakeViewController () <UITextFieldDelegate>

@property (nonatomic) BOOL isEditMode;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIButton *mapCheckRefOriginY;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *segmentedTopMargin;
@property (weak, nonatomic) IBOutlet UITextField *pinNameTextField;

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


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //NavigationBar 숨기기
    [self.navigationController setNavigationBarHidden:YES];
    
    [self.pinNameTextField addTarget:self action:@selector(textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
    
    NSArray *myMap = @[@[@1, @"기억할만한 장소"],
                       @[@0, @"목동 맛집"],
                       @[@1, @"패스트캠퍼스 맛집"]];
    
    [self makeMyMapCheckBtnViewWithArr:myMap];
    // constraint의 property를 정의해서 맵이 늘어날수록 constraint가 대응하도록 한다
    self.segmentedTopMargin.constant = 30 + 44 * (myMap.count - 1);
    // 변동 constraint를 준 후 반드시 명령
    [self.view layoutIfNeeded];
    
    ////////////// 만들기 상태. 밖에서 수정하기로 들어오기 전까지 ///////////////
    self.isEditMode = YES;
    
    self.checkName = YES;
    self.checkCategory = YES;
    self.checkMap = YES;
    [self checkMakeBtnState];
    
    self.pinNameTextField.text = @"패스트캠퍼스";
    //////////////////////////////////////////////////////////////////
    
    if (self.isEditMode) {
        [self.makeBtn2 setTitle:@"수정하기" forState:UIControlStateNormal];
//        [self.view layoutIfNeeded];
        //        float makeBtnCenterX = + (self.makeBtn3.frame.size.width/2)-25;
        self.deleteBtn = [[UIButton alloc] init];
        [self.deleteBtn setFrame:CGRectMake(self.makeBtn3.frame.origin.x+3, self.makeBtn3.frame.origin.y+70, 34, 44)];
        [self.deleteBtn setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
        [self.contentView addSubview:self.deleteBtn];
        [self.deleteBtn addTarget:self action:@selector(selectedDeletePinBtn:) forControlEvents:UIControlEventTouchUpInside];
    }

}

- (void)textFieldEditingChanged:(UITextField *)sender {
    
    if ([sender.text isEqualToString:@""]) {
        self.checkName = NO;
    } else {
        self.checkName = (BOOL)sender.text;
    }
    
    [self checkMakeBtnState];
}

- (void)makeMyMapCheckBtnViewWithArr:(NSArray *)arr {
    
    self.mapCheckBtnArr = [[NSMutableArray alloc] init];
    
    CGFloat offsetY = self.mapCheckRefOriginY.frame.origin.y;
    
    for (NSInteger i =0 ; i < arr.count ; i++) {
        UIView *btnView = [[UIView alloc] initWithFrame:CGRectMake(26, offsetY, self.view.frame.size.width-26, 29)];
        [self.contentView addSubview:btnView];
        
        UIButton *mapCheckBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [mapCheckBtn setImage:[UIImage imageNamed:@"mapCheckBtn"] forState:UIControlStateNormal];
        [mapCheckBtn setImage:[UIImage imageNamed:@"mapSelectBtn"] forState:UIControlStateSelected];
        [mapCheckBtn setContentMode:UIViewContentModeScaleAspectFit];
        
        UIButton *mapNameBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [mapNameBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [mapNameBtn setTitle:arr[i][1] forState:UIControlStateNormal];
        [mapNameBtn setTitleColor:[UIColor colorWithRed:84/255.0 green:182/255.0 blue:249/255.0 alpha:1.0] forState:UIControlStateNormal];
        [mapNameBtn.titleLabel setFont:[UIFont systemFontOfSize:20]];
        
        mapCheckBtn.tag = i;
        mapNameBtn.tag = i;
        [self.mapCheckBtnArr addObject:mapCheckBtn];
        
        
        [mapCheckBtn addTarget:self action:@selector(selectedMapCheckBtn:) forControlEvents:UIControlEventTouchUpInside];
        [mapNameBtn addTarget:self action:@selector(selectedMapCheckBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        // 자물쇠가 있을 경우
        if ([arr[i][0] isEqual:@1]) {
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
    }
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    //NavigationBar 숨긴거 되살리기
    [self.navigationController setNavigationBarHidden:NO];

}

- (IBAction)selectedPopViewBtn:(id)sender {
    
    //Navigation없애고 커스텀 버튼으로 POP
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.pinNameTextField resignFirstResponder];
    
    return YES;
}

- (IBAction)textFieldResignTapGesture:(id)sender {
    
    [self.pinNameTextField resignFirstResponder];
}

//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    [super touchesBegan:touches withEvent:event];
//    NSLog(@"touchesBegan");
//    UITouch *touch = [[event allTouches] anyObject];
//    if ([touch view] != self.pinNameTextField) {
//        [self.pinNameTextField resignFirstResponder];
//
//    }
//}

- (IBAction)selecedCategoryBtn:(UIButton *)sender {
    NSLog(@"%ld", sender.tag);
    
    // Radio Button
    if (sender.tag != self.categoryLastSelectedBtn.tag) {
        self.categoryLastSelectedBtn.selected = NO;
        
        self.categoryLastSelectedBtn = sender;
        sender.selected = YES;
    }
    
    self.checkCategory = YES;
    [self checkMakeBtnState];
}


- (void)selectedMapCheckBtn:(UIButton *)sender {

    if (self.mapCheckBtnArr[sender.tag] == self.mapLastSelectedBtn) {
        self.mapLastSelectedBtn.selected = !self.mapLastSelectedBtn.selected;
    } else {
        // 누르면 해당 누른버튼 yes
        self.mapCheckBtnArr[sender.tag].selected = YES;
        // 라스트버튼값은 초기화
        self.mapLastSelectedBtn.selected = NO;
        // 해당 누른버튼을 라스트버튼으로
        self.mapLastSelectedBtn = self.mapCheckBtnArr[sender.tag];
    }
    
// 최소 한개이상의  맵체크했을 때 만들기 활성화. 삼항연산자 참이면 앞에꺼
    self.checkMap = self.mapCheckBtnArr[sender.tag].selected ? YES : NO;
// 같은 조건식.
//    if (self.mapCheckBtnArr[sender.tag].selected) {
//        // YES
//        self.checkMap = YES;
//    } else {
//        // NO
//        self.checkMap = NO;
//    }

    [self checkMakeBtnState];
    
    
//    // 토글버튼. 체크된건 안되게, 안된건 되게
//    self.mapCheckBtnArr[sender.tag].selected = !self.mapCheckBtnArr[sender.tag].selected;
//    self.checkMap = NO;
//
//
//    if (sender.tag != self.mapCheckBtnArr[sender.tag]) {
//        self.mapLastSelectedBtn.selected = NO;
//        self.mapLastSelectedBtn = sender;
//        sender.selected = YES;
//    }
//    
//
//    for (UIButton *mapBtn in self.mapCheckBtnArr) {
//        
//        if (mapBtn.selected == YES) {
//            self.checkMap = YES;
//            break;
//        }
//    }
//    [self checkMakeBtnState];
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

- (IBAction)selectedMakeBtn {
    
    NSString *mapStr = [[NSString alloc] init];
    // string형태로 맵체크 정보를 저장. ex. 010112
    for (NSInteger i=0 ; i < self.mapCheckBtnArr.count ; i++) {
        if (self.mapCheckBtnArr[i].selected == YES) {
            mapStr = [NSString stringWithFormat:@"%@ %ld", mapStr, i];
        }
    }
    
    [self makePinWithName:self.pinNameTextField.text
             withCategory:self.categoryLastSelectedBtn.tag
          withSelectedMap:mapStr];
    
    [self.navigationController popViewControllerAnimated:YES];
}


// 아마 데이터 센터에 추가 될 메서드 (일단 예시로 여기다 만들어놓음)
- (void)makePinWithName:(NSString *)name
           withCategory:(NSInteger)category
        withSelectedMap:(NSString *)mapStr {
    // 알아서 안에서 데이터 처리~~~
    
    NSLog(@"name : %@", name);
    NSLog(@"category : %ld", category);
    NSLog(@"mapStr : %@", mapStr);
}

- (void)selectedDeletePinBtn:(id)sender {
    
    NSLog(@"핀 지워");
    [self.navigationController popViewControllerAnimated:YES];
}

@end
