//
//  MakeViewController.m
//  Momo
//
//  Created by Jeheon Choi on 2017. 4. 4..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import "MakeViewController.h"

@interface MakeViewController ()

@property (weak, nonatomic) IBOutlet UIButton *makeMapBtn;
@property (weak, nonatomic) IBOutlet UIButton *makePinBtn;

@end

@implementation MakeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // 버튼 기본 세팅
    self.makeMapBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
    self.makeMapBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    self.makeMapBtn.layer.cornerRadius = self.makeMapBtn.frame.size.height/2;
    self.makeMapBtn.layer.borderColor = [UIColor whiteColor].CGColor;
//    self.makeMapBtn.layer.borderWidth = 2;
    
    self.makePinBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
    self.makePinBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    self.makePinBtn.layer.cornerRadius = self.makePinBtn.frame.size.height/2;
    self.makePinBtn.layer.borderColor = [UIColor whiteColor].CGColor;
//    self.makePinBtn.layer.borderWidth = 2;

    // Target이 parentViewController(Main Tab Bar Controller)
    [self.makeMapBtn addTarget:(MainTabBarController *)self.parentViewController action:@selector(selectedMakeMapBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.makePinBtn addTarget:(MainTabBarController *)self.parentViewController action:@selector(selectedMakePinBtn:) forControlEvents:UIControlEventTouchUpInside];
}


// 버튼 외 다른 곳 터치할 때, MakeView removeFromSuperview
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    UITouch *touch = [[event allTouches] anyObject];
    if (([touch view] != self.makeMapBtn) && ([touch view] != self.makePinBtn)) {
        [self.view removeFromSuperview];
    }
}


@end
