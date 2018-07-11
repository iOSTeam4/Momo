//
//  PostMakeViewController.m
//  Momo
//
//  Created by Hanson Jung on 2017. 4. 7..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import "PostMakeViewController.h"
#import "PostViewController.h"

@class UIPlaceHolderTextView;

@interface PostMakeViewController ()
<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *userCommentTextView;
@property (nonatomic) NSInteger pin_pk;

@property (nonatomic) BOOL isEditMode;
@property (nonatomic) MomoPostDataSet *postData;

@property (weak, nonatomic) IBOutlet UILabel *viewTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *pinNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *pinAddressLabel;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) UIImageView *photoImageView;
@property (nonatomic) UIImage *chosenImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *photoBtnTopSpacingConstraint;
@property (nonatomic) NSLayoutConstraint *originphotoBtnTopSpacingConstraintY;
@property (weak, nonatomic) IBOutlet UIButton *photoUploadBtn;
@property (weak, nonatomic) UIButton *deletePhoto;
//@property (weak, nonatomic) IBOutlet UITextView *contentTextField;

@property (nonatomic) BOOL checkTextView;

@property (weak, nonatomic) IBOutlet UIButton *makeBtn1;
@property (weak, nonatomic) IBOutlet UIButton *makeBtn2;
@property (weak, nonatomic) IBOutlet UIButton *makeBtn3;
@property (weak, nonatomic) UIButton *deleteBtn;

@end

@implementation PostMakeViewController


// 생성할 때, 미리 부르는 메서드
- (void)setMakeModeWithPinPK:(NSInteger)pin_pk {
    self.pin_pk = pin_pk;
}

// 수정할 때, 미리 부르는 메서드
- (void)setEditModeWithPostData:(MomoPostDataSet *)postData {
    self.postData = postData;
    self.pin_pk = postData.post_pin_pk;
    self.isEditMode = YES;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 핀 정보 세팅
    MomoPinDataSet *pinData = [DataCenter findPinDataWithPinPK:self.pin_pk];
    self.pinNameLabel.text = pinData.pin_name;
    self.pinAddressLabel.text = pinData.pin_place.place_address;
    
    // 텍스트뷰 노티 설정
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewEditChanged) name:UITextViewTextDidChangeNotification object:nil];

    
    // Photo ImgView Setting
    // 사진불러올 이미지뷰를 생성만 해놓고 hidden. 실제 사진을 불러오면 그때 아래 버튼이하 항목들을 밀어낸다.
    UIImageView *photoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(26, self.photoUploadBtn.frame.origin.y, self.view.frame.size.width-26, self.view.frame.size.width-26)];
    self.photoImageView = photoImageView;
    [self.photoImageView setHidden:YES];
    [self.contentView addSubview:self.photoImageView];
    self.originphotoBtnTopSpacingConstraintY.constant = self.photoBtnTopSpacingConstraint.constant;
    
    // Delete Photo Btn Setting
    UIButton *deletePhoto = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 40, self.photoUploadBtn.frame.origin.y + 20, 26, 26)];
    self.deletePhoto = deletePhoto;
    [self.deletePhoto setImage:[UIImage imageNamed:@"cross"] forState:UIControlStateNormal];
    [self.deletePhoto setHidden:YES];
    [self.deletePhoto addTarget:self action:@selector(deleteImage:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.deletePhoto];
    
    
    // EditMode
    if (self.isEditMode) {
        NSLog(@"PostMakeViewController isEditMode");
        
        [self.view layoutIfNeeded];     // viewDidLoad에서 View Layout 맞추기 (삭제버튼 위치)
        
        // Edit 모드에 맞게 수정
        self.viewTitleLabel.text = @"포스트 수정하기";
        [self.makeBtn2 setTitle:@"수정하기" forState:UIControlStateNormal];
        
        
        // 기존 포스트 정보 넣기 -------------------//

        // 사진
        if ([self.postData.post_photo_data length]) {
            
            self.photoImageView.image = [self.postData getPostPhoto];       // 사진 설정
            self.photoBtnTopSpacingConstraint.constant = self.photoImageView.frame.size.height + self.photoBtnTopSpacingConstraint.constant + 20.0; // Constraint 조정
            [self.view layoutIfNeeded];
            
            self.contentView.frame = CGRectMake(self.contentView.frame.origin.x, self.contentView.frame.origin.y, self.contentView.frame.size.width, self.makeBtn3.frame.origin.y + self.makeBtn3.frame.size.height + 30);  // 스크롤뷰 Content뷰 사이즈 조정

            self.photoImageView.hidden = NO;    // 사진 노출
            self.deletePhoto.hidden = NO;       // 사진 삭제 버튼 노출
        }
        
        // 글
        if ([self.postData.post_description length]) {
            self.userCommentTextView.text = self.postData.post_description;
            self.checkTextView = YES;
        }
        
        // 삭제 버튼 추가
        UIButton *deleteBtn = [[UIButton alloc] init];
        self.deleteBtn = deleteBtn;
        [self.deleteBtn setFrame:CGRectMake(self.makeBtn3.frame.origin.x+3, self.makeBtn3.frame.origin.y+70, 34, 44)];
        [self.deleteBtn setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
        [self.deleteBtn addTarget:self action:@selector(selectedDeletePostBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.deleteBtn];
        
        [self checkMakeBtnState];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [GoogleAnalyticsModule startGoogleAnalyticsTrackingWithScreenName:@"PostMakeViewController"];
}

- (void)dealloc {
    // 텍스트뷰 노티 해제
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


// Discription(글) 관련 ----------------------------------//

// 스크롤 처리

- (void)textViewDidBeginEditing:(UITextView *)textView{
    if (self.photoImageView.hidden) {
        [self.scrollView setContentOffset:CGPointMake(0,200) animated:YES];
    } else {
        [self.scrollView setContentOffset:CGPointMake(0,500) animated:YES];
    }
    
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [self.scrollView setContentOffset:CGPointMake(0,0) animated:YES];

}


- (void)textViewEditChanged {
//    NSLog(@"textViewEditChanged");
    
    if ([self.userCommentTextView.text length] > 0) {
        self.checkTextView = YES;
    } else {
        self.checkTextView = NO;
    }
    
    [self checkMakeBtnState];
}


// 터치하면 텍스트필드 resign되게
- (IBAction)textViewResignTapGesture:(id)sender {
    [self.userCommentTextView resignFirstResponder];
}



// Photo 관련 --------------------------------//

// Photo Upload
- (IBAction)selectedPhotoUploadBtn:(id)sender {
    

    NSLog(@"photo btn!!!!");
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertCamera = [UIAlertController alertControllerWithTitle:nil
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];

        UIAlertAction *cameraBtn = [UIAlertAction actionWithTitle:@"Camera"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                              NSLog(@"Camera");
                                                          
                                                              [self selectedCamera];
        
                                                          }];
       
        UIAlertAction *photoBtn = [UIAlertAction actionWithTitle:@"Photo Library"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             NSLog(@"Photo Library");
                                                             
                                                             [self selectedPhoto];
                                                         }];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                         style:UIAlertActionStyleCancel
                                                       handler:nil];
                                     
        [alertCamera addAction:cameraBtn];
        [alertCamera addAction:photoBtn];
        [alertCamera addAction:cancel];
        [self presentViewController:alertCamera animated:YES completion:nil];
    });
    
}

- (void)selectedCamera {
    
    UIImagePickerController *cameraController = [[UIImagePickerController alloc] init];
    cameraController.sourceType = UIImagePickerControllerSourceTypeCamera;
    cameraController.allowsEditing = YES;
    cameraController.delegate = self;
    [self presentViewController:cameraController animated:YES completion:nil];
}

- (void)selectedPhoto {
   
    UIImagePickerController *cameraController = [[UIImagePickerController alloc] init];
    cameraController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    cameraController.allowsEditing = YES;
    cameraController.delegate = self;
    [self presentViewController:cameraController animated:YES completion:nil];
    
}


// 이미지 선택 완료
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    //Image의 선택이 끝났을 때, 불리는 Method
    NSLog(@"info %@", info);
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    self.photoImageView.image = info[UIImagePickerControllerEditedImage];
    
    // 사진 Hidden되어있었을 때
    if (self.photoImageView.hidden) {
        [self.photoImageView setHidden:NO];
        [self.deletePhoto setHidden:NO];
        
        self.photoBtnTopSpacingConstraint.constant = self.photoImageView.frame.size.height + self.photoBtnTopSpacingConstraint.constant + 20.0;
        [self.view layoutIfNeeded];     // autolayout constraint 값을 코드로 변경한 걸 적용할 때 꼭!!!!
        
        self.contentView.frame = CGRectMake(self.contentView.frame.origin.x, self.contentView.frame.origin.y, self.contentView.frame.size.width, self.makeBtn3.frame.origin.y + self.makeBtn3.frame.size.height + 30);

        // DeleteBtn Frame setting (Edit Mode 일 때만 해당되긴하나, 구분없이 이렇게 불러도 상관없음)
        [self.deleteBtn setFrame:CGRectMake(self.makeBtn3.frame.origin.x+3, self.makeBtn3.frame.origin.y+70, 34, 44)];
    }
    
    [self.scrollView setContentOffset:CGPointMake(0,400) animated:YES];

    [self checkMakeBtnState];
}

// 이미지 삭제
- (void)deleteImage:(UIButton *)sender {
    NSLog(@"click deletePhoto");
    
    self.photoImageView.image = nil;        // 사진 데이터도 초기화
    [self.photoImageView setHidden:YES];
    [self.deletePhoto setHidden:YES];
    
    self.photoBtnTopSpacingConstraint.constant = 20;
    
    [self.view layoutIfNeeded];
    [self.scrollView setContentOffset:CGPointMake(0,0) animated:YES];
    
    // DeleteBtn Frame setting (Edit Mode 일 때만 해당되긴하나, 구분없이 이렇게 불러도 상관없음)
    [self.deleteBtn setFrame:CGRectMake(self.makeBtn3.frame.origin.x+3, self.makeBtn3.frame.origin.y+70, 34, 44)];
    
    [self checkMakeBtnState];
}



// Make Btn 활성화 확인 메서드 -----------------//

- (void)checkMakeBtnState {
    
    if ((self.photoImageView.hidden == NO) || self.checkTextView) {
        for (UIButton *btn in @[self.makeBtn1, self.makeBtn2, self.makeBtn3]) [btn setEnabled:YES];
    } else {
        for (UIButton *btn in @[self.makeBtn1, self.makeBtn2, self.makeBtn3]) [btn setEnabled:NO];
    }
}



// Back, Make, Del Btn Action ------------------------//

// Back Btn Action
- (IBAction)selectedBackBtn:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}



// Make Btn Action
- (IBAction)selectedMakeBtn {
    
    // 키보드 내리기
    [self.userCommentTextView resignFirstResponder];
    
    NSData *photodata = [UtilityModule imgResizing:self.photoImageView.image];    // 이미지 리사이징 (nil처리까지 알아서 함)
    
    
    [UtilityModule showIndicator];
    
    if (!self.isEditMode) {     // 만들기
        NSLog(@"새 포스트 만들어!");
        
        [[NetworkModule momoNetworkManager]
         createPostRequestWithPinPK:self.pin_pk
         withPhotoData:UIImageJPEGRepresentation(self.photoImageView.image, 0.3)
         withDescription:self.userCommentTextView.text
         withCompletionBlock:^(BOOL isSuccess, NSString *result) {
                                                       
             [UtilityModule dismissIndicator];
             
             if (isSuccess) {
                 
                 self.postData = [[MomoPostDataSet allObjects] lastObject];      // 새로 생성된 데이터가 lastObject
                 
                 if (self.wasPostView) {       // post뷰에서 넘어왔을 때
                     [self dismissViewControllerAnimated:YES completion:nil];
                     
                 } else {
                     [self showPostView];
                 }
                 
             } else {
                 
                 [UtilityModule presentCommonAlertController:self withMessage:result];
                 
             }
             
         }];
        
        
    } else {    // 수정하기
        NSLog(@"포스트 수정해!");
        
        [[NetworkModule momoNetworkManager]
         updatePostRequestWithPostPK:self.postData.pk
         WithPinPK:self.pin_pk
         withPhotoData:photodata
         withDescription:self.userCommentTextView.text
         withCompletionBlock:^(BOOL isSuccess, NSString *result) {
             
             [UtilityModule dismissIndicator];
             
             if (isSuccess) {
                 if (self.wasPostView) {       // post뷰에서 넘어왔을 때
                     [((PostViewController *)((UINavigationController *)((MainTabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController).selectedViewController).topViewController) showSelectedPostAndSetPostData:self.postData];    // 다시 수정된 포스트 중심으로 보이게 세팅
                     [self dismissViewControllerAnimated:YES completion:nil];
                     
                 } else {
                     [self showPostView];
                 }
                 
             } else {
                 [UtilityModule presentCommonAlertController:self withMessage:result];
             }
             
         }];
    }
}


- (void)showPostView {
    UIStoryboard *pinPostStoryBoard = [UIStoryboard storyboardWithName:@"PinPost" bundle:nil];
    PostViewController *postVC = [pinPostStoryBoard instantiateViewControllerWithIdentifier:@"PostViewController"];
    
    // 포스트뷰 이동 전, 데이터 세팅
    [postVC showSelectedPostAndSetPostData:self.postData];
    
    // 만들어진 포스트뷰로 먼저 Push
    [((UINavigationController *)((MainTabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController).selectedViewController) pushViewController:postVC animated:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
}


// Delete Btn Action
- (void)selectedDeletePostBtn:(id)sender {
    NSLog(@"포스트 지워");

    // 키보드 내리기
    [self.userCommentTextView resignFirstResponder];
    
    [UtilityModule showIndicator];
    
    [[NetworkModule momoNetworkManager]
     deletePostRequestWithPostData:self.postData
     withCompletionBlock:^(BOOL isSuccess, NSString *result) {
         
         [UtilityModule dismissIndicator];
         
         if (isSuccess) {
             
             [((MainTabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController) mainTabBarAnotherVCPopToRootViewController];   // Delete popToRootView처리
             
             if ([DataCenter findPinDataWithPinPK:self.pin_pk].pin_post_list.count > 0) {
                 
                 // 남은 포스트 양이 1개 이상 남아있을 때, 테이블 뷰로 돌아감
                 [self dismissViewControllerAnimated:YES completion:nil];
                 
             } else {
                 [((UINavigationController *)((MainTabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController).selectedViewController) popViewControllerAnimated:NO];   // 테이블 뷰에서 빠져나와 PinView로 먼저 이동
                 [self dismissViewControllerAnimated:YES completion:nil];
             }
             
             
         } else {
             [UtilityModule presentCommonAlertController:self withMessage:result];
         }
         
     }];
    
}


@end
