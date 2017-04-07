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

@property (weak, nonatomic) IBOutlet UIButton *photoUploadBtn;
@property (weak, nonatomic) IBOutlet UITextField *contentTextField;

@property (weak, nonatomic) IBOutlet UIButton *cafeBtn;
@property (weak, nonatomic) IBOutlet UIButton *foodBtn;
@property (weak, nonatomic) IBOutlet UIButton *shopBtn;
@property (weak, nonatomic) IBOutlet UIButton *placeBtn;
@property (weak, nonatomic) IBOutlet UIButton *etcBtn;
@property (weak, nonatomic) UIButton *categoryLastSelectedBtn;

@property (nonatomic) BOOL checkCategory;
@property (nonatomic) BOOL checkTextField;
@property (nonatomic) BOOL checkPhoto;

@property (weak, nonatomic) IBOutlet UIButton *makeBtn1;
@property (weak, nonatomic) IBOutlet UIButton *makeBtn2;
@property (weak, nonatomic) IBOutlet UIButton *makeBtn3;

@end

@implementation PostMakeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO];
    [self.contentTextField addTarget:self action:@selector(textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
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


- (void)textFieldEditingChanged:(UITextField *)sender {
    
    if ([sender.text isEqualToString:@""]) {
        self.checkTextField = NO;
    } else {
        self.checkTextField = (BOOL)sender.text;
    }
    
    [self checkMakeBtnState];
}

- (IBAction)selectedCategoryBtn:(UIButton *)sender {
    
    if (sender.tag != self.categoryLastSelectedBtn.tag) {
        self.categoryLastSelectedBtn.selected = NO;
        self.categoryLastSelectedBtn = sender;
        sender.selected = YES;
    }
    self.checkCategory = YES;
    [self checkMakeBtnState];
    
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [self.contentTextField resignFirstResponder];
    
    return YES;
    
}

- (void)checkMakeBtnState {
    
    
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


//Image의 선택이 끝났을 때, 불리는 Method
//#pragma mark- UpdateViewController didFinishPickingMediaWithInfo Delegate Method
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSLog(@"info %@", info);
//    self.updateViewBackgroundPhoto.image = [info objectForKey:UIImagePickerControllerEditedImage];;
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

@end
