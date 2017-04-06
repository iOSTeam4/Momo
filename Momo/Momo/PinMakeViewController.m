//
//  PinMakeViewController.m
//  Momo
//
//  Created by Hanson Jung on 2017. 4. 4..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import "PinMakeViewController.h"

@interface PinMakeViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *scrContentView;
@property (weak, nonatomic) IBOutlet UIButton *mapCheckRefOriginY;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *segmentedTopMargin;
@property (weak, nonatomic) IBOutlet UITextField *pinNameTextField;

@property (weak, nonatomic) UIButton *categoryLastSelectedBtn;

@property (nonatomic) NSMutableArray<UIButton *> *mapCheckBtnArr;

@property (weak, nonatomic) IBOutlet UISwitch *publicSwitch;

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
    
    self.segmentedTopMargin.constant = 30 + 44 * (myMap.count - 1);
    [self.view layoutIfNeeded];

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
        [self.scrContentView addSubview:btnView];
        
        UIButton *mapCheckBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [mapCheckBtn setImage:[UIImage imageNamed:@"mapCheckBtn"] forState:UIControlStateNormal];
        [mapCheckBtn setImage:[UIImage imageNamed:@"mapCheckBtnS"] forState:UIControlStateSelected];
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
        
        if ([arr[i][0] isEqual:@1]) {
            [mapNameBtn setImage:[UIImage imageNamed:@"lockBtnClose"] forState:UIControlStateNormal];
            [mapNameBtn setContentMode:UIViewContentModeScaleAspectFit];
        }
        
        
        [btnView addSubview:mapCheckBtn];
        mapCheckBtn.frame = CGRectMake(0, 0, 29, 29);
        
        [btnView addSubview:mapNameBtn];
        mapNameBtn.frame = CGRectMake(40, 0, btnView.frame.size.width - 40, 29);
        
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

- (IBAction)selecedCategoryBtn:(UIButton *)sender {
    NSLog(@"%d", sender.tag);
    
    if (sender.tag != self.categoryLastSelectedBtn.tag) {
        self.categoryLastSelectedBtn.selected = NO;
        
        self.categoryLastSelectedBtn = sender;
        sender.selected = YES;
    }
    
    self.checkCategory = YES;
    [self checkMakeBtnState];
}


- (void)selectedMapCheckBtn:(UIButton *)sender {
    
    self.mapCheckBtnArr[sender.tag].selected = !self.mapCheckBtnArr[sender.tag].selected;

    self.checkMap = NO;
    for (UIButton *mapBtn in self.mapCheckBtnArr) {
        if (mapBtn.selected == YES) {
            self.checkMap = YES;
            break;
        }
    }
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


- (IBAction)selectedMakeBtn {
    
    NSString *mapStr = [[NSString alloc] init];
    
    for (NSInteger i=0 ; i < self.mapCheckBtnArr.count ; i++) {
        if (self.mapCheckBtnArr[i].selected == YES) {
            mapStr = [NSString stringWithFormat:@"%@ %d", mapStr, i];
        }
    }
    
    [self makePinWithName:self.pinNameTextField.text
             withCategory:self.categoryLastSelectedBtn.tag
          withSelectedMap:mapStr
              withPrivate:self.publicSwitch.on];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    NSLog(@"touchesBegan");
    UITouch *touch = [[event allTouches] anyObject];
    if ([touch view] != self.pinNameTextField) {
        [self.pinNameTextField resignFirstResponder];

    }
}


// 아마 데이터 센터에 추가 될 메서드 (일단 예시로 여기다 만들어놓음)
- (void)makePinWithName:(NSString *)name
           withCategory:(NSInteger)category
        withSelectedMap:(NSString *)mapStr
            withPrivate:(BOOL)private {
    // 알아서 안에서 데이터 처리~~~
    
    NSLog(@"name : %@", name);
    NSLog(@"category : %ld", category);
    NSLog(@"mapStr : %@", mapStr);
    NSLog(@"private : %d", private);
}




@end
