//
//  UserProfileEditViewController.m
//  Momo
//
//  Created by Jeheon Choi on 2017. 4. 9..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import "UserProfileEditViewController.h"
#import "UIPlaceHolderTextView.h"

@interface UserProfileEditViewController () <UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *userImgView;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UILabel *userIDLabel;

@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *userCommentTextView;

@end

@implementation UserProfileEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self initialSetting];  // UI 관련 설정들 있어서, viewWillAppear에서 호출
                            // 그럼에도 피카츄 찌그러짐.. 시점 이슈 해결 필요
}

- (void)initialSetting {
    
    // 프로필 사진
    [self.userImgView.layer setCornerRadius:self.userImgView.frame.size.height/2];      // 프사 동그랗게
    
    UITapGestureRecognizer *userImgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImgView)];
    [self.userImgView setUserInteractionEnabled:YES];
    [self.userImgView addGestureRecognizer:userImgTap];
    
    // 프로필 소개 TextView
    self.userCommentTextView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.userCommentTextView.layer.borderWidth = 0.5;
    
}





// Img 탭했을 때, 불리는 메서드
- (void)tapImgView {
    NSLog(@"tapImgView");
    self.userImgView.image = [UIImage imageNamed:@"pika2.png"];
    
    
    
    // 얼럿, 카메라 부분 모듈화 정리 필요!
    
    UIAlertController *alertCamera = [UIAlertController alertControllerWithTitle:nil
                                                                         message:nil
                                                                  preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cameraBtn = [UIAlertAction actionWithTitle:@"Camera"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
                                                          NSLog(@"Camera");
                                                          
                                                          [self camera];
                                                          
                                                      }];
    
    UIAlertAction *photoBtn = [UIAlertAction actionWithTitle:@"Photo Library"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                         NSLog(@"Photo Library");
                                                         
                                                         [self photo];
                                                     }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction * _Nonnull action) {}];
    
    [alertCamera addAction:cameraBtn];
    [alertCamera addAction:photoBtn];
    [alertCamera addAction:cancel];
    
    [self presentViewController:alertCamera animated:YES completion:nil];
}


- (void)camera {
    
    UIImagePickerController *cameraController = [[UIImagePickerController alloc] init];
    cameraController.sourceType = UIImagePickerControllerSourceTypeCamera;
    cameraController.allowsEditing = YES;
    cameraController.delegate = self;
    [self presentViewController:cameraController animated:YES completion:nil];
}

- (void)photo {
    
    UIImagePickerController *cameraController = [[UIImagePickerController alloc] init];
    cameraController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    cameraController.allowsEditing = YES;
    cameraController.delegate = self;
    [self presentViewController:cameraController animated:YES completion:nil];
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSLog(@"didFinishPickingMediaWithInfo");
    
    NSLog(@"%@", info);
    self.userImgView.image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}


// TextField, TextView 키보드 처리

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    NSLog(@"touchesBegan");
    UITouch *touch = [[event allTouches] anyObject];
    if ([self.userNameTextField isFirstResponder] || [self.userCommentTextView isFirstResponder]) {
        if (([touch view] != self.userNameTextField) && ([touch view] != self.userCommentTextView)) {
            [self.userNameTextField resignFirstResponder];
            [self.userCommentTextView resignFirstResponder];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
}



@end
