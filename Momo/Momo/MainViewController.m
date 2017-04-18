//
//  MainViewController.m
//  Momo
//
//  Created by Jeheon Choi on 2017. 3. 27..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import "MainViewController.h"
#import "MainTabBarController.h"

@interface MainViewController ()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end


@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.navigationItem setTitle:@"Main View"];
    
    _imageView.image = [[DataCenter sharedInstance].momoUserData getUserProfileImage];
    [self.view addSubview:_imageView];
    _imageView.frame = CGRectMake(0, 0, 30, 30);
    
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [GoogleAnalyticsModule startGoogleAnalyticsTrackingWithScreenName:@"MainViewController"];
    
    NSLog(@"MainViewController : viewWillAppear");

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.imageView setImage:[[DataCenter sharedInstance].momoUserData getUserProfileImage]];
}

- (IBAction)logoutTempBtnAction:(id)sender {
    
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


