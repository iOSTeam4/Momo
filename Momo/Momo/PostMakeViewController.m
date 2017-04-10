//
//  PostMakeViewController.m
//  Momo
//
//  Created by Hanson Jung on 2017. 4. 7..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import "PostMakeViewController.h"

@interface PostMakeViewController ()
<UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (nonatomic) UIImageView *photoImageView;
@property (nonatomic) UIImage *chosenImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *photoBtnTopSpacingConstraint;

@property (weak, nonatomic) IBOutlet UIButton *photoUploadBtn;
@property (weak, nonatomic) IBOutlet UITextField *contentTextField;

@property (nonatomic) BOOL checkTextField;

@property (weak, nonatomic) IBOutlet UIButton *makeBtn1;
@property (weak, nonatomic) IBOutlet UIButton *makeBtn2;
@property (weak, nonatomic) IBOutlet UIButton *makeBtn3;

@end

@implementation PostMakeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    [self.contentTextField addTarget:self action:@selector(textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
    
    self.photoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(26, self.photoUploadBtn.frame.origin.y, self.view.frame.size.width-26, self.view.frame.size.width-26)];
    [self.contentView addSubview:self.photoImageView];
    [self.photoImageView setHidden:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}


- (IBAction)selectedBackBtn:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}



- (IBAction)selectedPhotoUplaodBtn:(id)sender {
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        //                    self.errorAlert.text = @"아이디 혹은 비밀번호를 다시 확인하세요.";
//        
//        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"어맛!"
//                                                                                 message:@"이미 존재하는 아이디예요"
//                                                                          preferredStyle:UIAlertControllerStyleAlert];
//        
//        UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"확인"
//                                                           style:UIAlertActionStyleDefault
//                                                         handler:^(UIAlertAction * _Nonnull action) {
//                                                             NSLog(@"확인버튼이 클릭되었습니다");
//                                                             
//                                                         }];
//        [alertController addAction:okButton];
//        
//        [self presentViewController:alertController animated:YES completion:nil];
    NSLog(@"photo btn!!!!");
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertCamera = [UIAlertController alertControllerWithTitle:nil
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *cameraBtn = [UIAlertAction actionWithTitle:@"Camera"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
                                                          NSLog(@"ok click!");
                                                          
                                                          [self camera];
        
                                                      }];
       
        UIAlertAction *photoBtn = [UIAlertAction actionWithTitle:@"Photo Library"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
                                                          NSLog(@"ok click!");
                                                          
                                                          [self photo];
                                                      }];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             NSLog(@"ok click!");
                                    
                                                         }];

                                     
        [alertCamera addAction:cameraBtn];
        [alertCamera addAction:photoBtn];
        [alertCamera addAction:cancel];
        [self presentViewController:alertCamera animated:YES completion:nil];
    });
    
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

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (self.photoImageView.hidden) {
    [self.scrollView setContentOffset:CGPointMake(0,100) animated:YES];
    } else {
    [self.scrollView setContentOffset:CGPointMake(0,450) animated:YES];
    }
}

- (void)textFieldEditingChanged:(UITextField *)sender {
    
    if ([sender.text isEqualToString:@""]) {
        self.checkTextField = NO;
    } else {
        self.checkTextField = (BOOL)sender.text;
    }
    
    [self checkMakeBtnState];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [self.contentTextField resignFirstResponder];
    
    return YES;
    
}

// 터치하면 텍스트필드 resign되게
- (IBAction)textFiedlResignTapGesture:(id)sender {
    
    [self.contentTextField resignFirstResponder];
}

//Image의 선택이 끝났을 때, 불리는 Method
//#pragma mark- UpdateViewController didFinishPickingMediaWithInfo Delegate Method
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSLog(@"info %@", info);
//    self.updateViewBackgroundPhoto.image = [info objectForKey:UIImagePickerControllerEditedImage];;
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    if (self.photoImageView.hidden) {
        self.photoBtnTopSpacingConstraint.constant = self.photoImageView.frame.size.height + self.photoBtnTopSpacingConstraint.constant + 20.0;
        [self.view layoutIfNeeded];     // autolayout constraint 값을 코드로 변경한 걸 적용할 때 꼭!!!!
    }
    
    self.photoImageView.image = info[UIImagePickerControllerEditedImage];
    [self.photoImageView setHidden:NO];
 
    
    self.contentView.frame = CGRectMake(self.contentView.frame.origin.x, self.contentView.frame.origin.y, self.contentView.frame.size.width, self.makeBtn3.frame.origin.y + self.makeBtn3.frame.size.height + 30);
   
    [self.scrollView setContentOffset:CGPointMake(0,400) animated:YES];
    [self checkMakeBtnState];
}

- (void)checkMakeBtnState {
    
    if (self.photoImageView.hidden == 0 && self.checkTextField) {
        [self.makeBtn1 setEnabled:YES];
        [self.makeBtn2 setEnabled:YES];
        [self.makeBtn3 setEnabled:YES];
    } else {
        [self.makeBtn1 setEnabled:NO];
        [self.makeBtn2 setEnabled:NO];
        [self.makeBtn3 setEnabled:NO];
    }
    
}

@end
