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
    [self.userNameTextField addTarget:self action:@selector(editDoneBtnSetEnabled) forControlEvents:UIControlEventEditingChanged];
    
    // UIPlaceHolderTextView descriptionEditChanged noti 추가
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editDoneBtnSetEnabled) name:UITextViewTextDidChangeNotification object:nil];
    
    
    
    // 데이터 세팅
    if ([DataCenter sharedInstance].momoUserData.user_author.profile_img_data) {
        self.userImgView.image  = [[DataCenter sharedInstance].momoUserData.user_author getAuthorProfileImg];           // 프사
    }
    self.userNameTextField.text = [DataCenter sharedInstance].momoUserData.user_author.username;                        // 이름
    self.userIDLabel.text   = [NSString stringWithFormat:@"@%@", [DataCenter sharedInstance].momoUserData.user_id];     // 아이디
    self.userCommentTextView.text = [DataCenter sharedInstance].momoUserData.user_description;                          // 유저 코멘트

}



- (void)viewWillAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [GoogleAnalyticsModule startGoogleAnalyticsTrackingWithScreenName:@"UserProfileEditViewController"];
    
    [self subviewSetting];  // UI 관련 설정들 있어서, viewWillAppear에서 호출
    
}

- (void)dealloc {
    // noti 해제
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

// UserName or Description 수정 했을 때, 불리는 Method
- (void)editDoneBtnSetEnabled {
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
    
    
    [UtilityModule showIndicator];
    
    [[NetworkModule momoNetworkManager]
     patchMemberProfileUpdateWithUsername:self.userNameTextField.text
     withProfileImgData:profileImgdata
     withDescription:self.userCommentTextView.text
     withCompletionBlock:^(BOOL isSuccess, NSString *result) {

         NSLog(@"finish updateMemberProfileWithUsername");
         
         [UtilityModule dismissIndicator];
         
         if (isSuccess) {
             NSLog(@"프로필 수정 완료");
             [self dismissViewControllerAnimated:YES completion:nil];
             
         } else {
             
             [UtilityModule presentCommonAlertController:self withMessage:result];
         }
     }];
    
}



// 로그아웃
- (IBAction)logOutBtnAtciton {
    NSLog(@"logOutBtnAtciton");
    
    // 키보드 처리
    [self.userNameTextField resignFirstResponder];
    [self.userCommentTextView resignFirstResponder];

    
    [UtilityModule showIndicator];
    
    [[NetworkModule momoNetworkManager] logOutRequestWithCompletionBlock:^(BOOL isSuccess, NSString *result) {
        
        [UtilityModule dismissIndicator];
        
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
