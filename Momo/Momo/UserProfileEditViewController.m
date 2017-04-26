//
//  UserProfileEditViewController.m
//  Momo
//
//  Created by Jeheon Choi on 2017. 4. 9..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import "UserProfileEditViewController.h"

@interface UserProfileEditViewController () <UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *userImgView;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UILabel *userIDLabel;

@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *userCommentTextView;


@property (weak, nonatomic) IBOutlet UIButton *editDoneBtn;

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
    
    
    // 임시 indicator ----------------------//
    
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
    [GoogleAnalyticsModule startGoogleAnalyticsTrackingWithScreenName:@"UserProfileEditViewController"];
    
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
    self.userImgView.image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    
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
- (IBAction)backBtnAtciton {
    NSLog(@"backBtnAtciton");
    
    // 키보드 처리
    [self.userNameTextField resignFirstResponder];
    [self.userCommentTextView resignFirstResponder];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

// 수정하기
- (IBAction)editDoneBtnAtciton {
    NSLog(@"editDoneBtnAtciton");
    
    // 키보드 처리
    [self.userNameTextField resignFirstResponder];
    [self.userCommentTextView resignFirstResponder];

    
    NSData *profileImgdata = [UtilityModule imgResizing:self.userImgView.image];    // 이미지 리사이징 (nil처리까지 알아서 함)
    
    if (profileImgdata.length > 1024*1024) {
        // 들어갈리가 없으나, 일단 예외 상황 로그 수집하기 위해 만들어 둠
        NSLog(@"Img Size Too Large");
        NSLog(@"Size of Image(bytes): %ld", profileImgdata.length);
        
    } else {

        [self.indicator startAnimating];
        
        [NetworkModule patchMemberProfileUpdateWithUsername:self.userNameTextField.text
                                         withProfileImgData:profileImgdata
                                            withDescription:self.userCommentTextView.text
                                        withCompletionBlock:^(BOOL isSuccess, NSString *result) {
                                            NSLog(@"finish updateMemberProfileWithUsername");
                                            
                                            [self.indicator stopAnimating];
                                            
                                            if (isSuccess) {
                                                NSLog(@"프로필 수정 완료");
                                                [self dismissViewControllerAnimated:YES completion:nil];
                                                
                                            } else {
                                                
                                                [UtilityModule presentCommonAlertController:self withMessage:result];
                                            }
                                        }];
        
    }
}



// 로그아웃
- (IBAction)logOutBtnAtciton {
    NSLog(@"logOutBtnAtciton");
    
    // 키보드 처리
    [self.userNameTextField resignFirstResponder];
    [self.userCommentTextView resignFirstResponder];

    
    [self.indicator startAnimating];
    
    [NetworkModule logOutRequestWithCompletionBlock:^(BOOL isSuccess, NSString *result) {
        
        [self.indicator stopAnimating];
        
        if (isSuccess) {
            NSLog(@"log out success : %@", result);
            
            UIStoryboard *loginStoryboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
            UIViewController *loginController = [loginStoryboard instantiateInitialViewController];
            
            [[UIApplication sharedApplication].keyWindow setRootViewController:loginController];
            [[UIApplication sharedApplication].keyWindow makeKeyAndVisible];
            
        } else {
            NSLog(@"error : %@", result);
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"oops!"
                                                                                     message:result
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"확인"
                                                               style:UIAlertActionStyleDefault
                                                             handler:nil];
            [alertController addAction:okButton];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }];
}

@end
