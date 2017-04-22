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


@property (weak, nonatomic) UIButton *editDoneBtn;
@property (weak, nonatomic) UIButton *backBtn;

@property (weak, nonatomic) UIActivityIndicatorView *indicator;

@end

@implementation UserProfileEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 수정하기 버튼 활성화 관련 selector 추가
    
    // UserImgView TapGestureRecognizer 추가
    UITapGestureRecognizer *userImgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImgView)];
    [self.userImgView setUserInteractionEnabled:YES];
    [self.userImgView addGestureRecognizer:userImgTap];

    // UserNameTextField userNameEditChanged 추가
    [self.userNameTextField addTarget:self action:@selector(userNameEditChanged) forControlEvents:UIControlEventEditingChanged];
    
    // UIPlaceHolderTextView descriptionEditChanged noti 추가
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(descriptionEditChanged:) name:UITextViewTextDidChangeNotification object:nil];
    
    
    // 임시 완료 버튼, indicator ----------------------//
    
    UIButton *editDoneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    editDoneBtn.frame = CGRectMake(self.view.frame.size.width-100, self.view.center.y, 50, 50);
    [editDoneBtn setTitle:@"완료" forState:UIControlStateNormal];
    [editDoneBtn setTitleColor:[UIColor mm_brightSkyBlueColor] forState:UIControlStateNormal];
    [editDoneBtn setTitle:@"완료" forState:UIControlStateDisabled];
    [editDoneBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [editDoneBtn addTarget:self action:@selector(editDoneBtnAtciton) forControlEvents:UIControlEventTouchUpInside];
    [editDoneBtn setEnabled:NO];    // 기본은 비활성화
    [self.view addSubview:editDoneBtn];
    self.editDoneBtn = editDoneBtn;
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(50, self.view.center.y, 50, 50);
    [backBtn setTitle:@"뒤로" forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor mm_brightSkyBlueColor] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtnAtciton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    self.backBtn = backBtn;
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.hidesWhenStopped = YES;
    indicator.center = self.view.center;
    self.indicator = indicator;
    [self.view addSubview:indicator];
    
    //---------------------------------------------//
    
    
    // 데이터 세팅
    if ([DataCenter sharedInstance].momoUserData.user_profile_image_data) {
        self.userImgView.image  = [[DataCenter sharedInstance].momoUserData getUserProfileImage];  // 프사
    }
    if ([DataCenter sharedInstance].momoUserData.user_username) {
        self.userNameTextField.text = [DataCenter sharedInstance].momoUserData.user_username;       // 이름
    }
//    if ([DataCenter sharedInstance].momoUserData.user_id) {
//        self.userIDLabel.text   = [NSString stringWithFormat:@"@%@", [DataCenter sharedInstance].momoUserData.user_id]; // 아이디
//    }
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self subviewSetting];  // UI 관련 설정들 있어서, viewWillAppear에서 호출
    
}

- (void)dealloc {
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
    
    // 노티 nil 처리 필요
}

- (void)subviewSetting {
    
    // 프로필 사진
    [self.userImgView.layer setCornerRadius:self.userImgView.frame.size.height/2];      // 프사 동그랗게
    
    // 프로필 소개 TextView
    self.userCommentTextView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.userCommentTextView.layer.borderWidth = 0.5;
    
}



// Camera, Photo Methods -----------------------------------------------//

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
    
    [self.editDoneBtn setEnabled:YES];      // 수정하기 버튼 활성화
}


// Keyboard 처리 ----------------------------//

// 화면 터치시 keyboard 내려가게
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

// Return keyboard 내려가게
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
}

// UserNameTextField EditChanged Selector Method
- (void)userNameEditChanged {
    [self.editDoneBtn setEnabled:YES];      // 수정하기 버튼 활성화
}





// UI Btn Action ---------------------------//

// 뒤로가기
- (void)backBtnAtciton {
    NSLog(@"backBtnAtciton");
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

// 수정하기
- (void)editDoneBtnAtciton {
    NSLog(@"editDoneBtnAtciton");
    

    
    // 이미지 리사이징 ------------//
    // 이미지 데이터 압축, 허용 용량 약 2.5mb정도
    // Point가 아닌, Pixel 사이즈로 조정됨 : 약 25kb img
    CGSize imgSize = CGSizeMake(500.0f, 500.0f);
    
    UIGraphicsBeginImageContext(imgSize);
    [self.userImgView.image drawInRect:CGRectMake(0,0,imgSize.width,imgSize.height)];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData *profileImgdata = UIImageJPEGRepresentation(resizedImage, 1);
    
    if (profileImgdata.length > 1024*1024) {
        // 들어갈리가 없으나, 일단 예외 상황 로그 수집하기 위해 만들어 둠
        NSLog(@"Img Size Too Large");
        NSLog(@"Size of Image(bytes): %ld", profileImgdata.length);
        
    } else {
        
        [self.indicator startAnimating];
        
        [NetworkModule patchMemberProfileUpdateWithUsername:self.userNameTextField.text
                                             withProfileImg:profileImgdata
                                        withCompletionBlock:^(BOOL isSuccess, NSString *result) {
                                            
                                            NSLog(@"finish updateMemberProfileWithUsername");
                                            
                                            [self.indicator stopAnimating];
                                            
                                            if (isSuccess) {
                                                NSLog(@"프로필 수정 완료");
                                                [self dismissViewControllerAnimated:YES completion:nil];
                                                
                                            } else {
                                                
                                                [UtilityCenter presentCommonAlertController:self withMessage:result];
                                            }
                                        }];
    }
    
}



@end
