//
//  PinViewController.m
//  Momo
//
//  Created by Jeheon Choi on 2017. 3. 28..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import "PinViewController.h"
#import "PinContentsCollectionViewCell.h"
#import "PinMarkerUIView.h"


@interface PinViewController ()
<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate>

@property (nonatomic) MomoMapDataSet *mapData;  // 접근한 지도 데이터
@property (nonatomic) NSInteger pinIndex;       // 핀 데이터 인덱스

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;
@property (weak, nonatomic) IBOutlet GMSMapView *mapPreView;
@property (weak, nonatomic) IBOutlet UIButton *mapPreViewBtn;

@property (weak, nonatomic) IBOutlet UIButton *setup;
@property (weak, nonatomic) IBOutlet UILabel *pinName;
@property (weak, nonatomic) IBOutlet UILabel *pinAddress;
@property (weak, nonatomic) IBOutlet UILabel *pinMainText;
@property (weak, nonatomic) IBOutlet UIImageView *userProfileImage;
@property (weak, nonatomic) IBOutlet UILabel *userNameToMade;
@property (weak, nonatomic) IBOutlet UILabel *date;

@property (nonatomic) NSArray *dataTempArr;

@end

@implementation PinViewController


// 초기 핀 데이터 세팅 ---------------------------------------//

- (void)showSelectedPinAndSetMapData:(MomoMapDataSet *)mapData withPinIndex:(NSInteger)pinIndex {
    self.mapData = mapData;
    self.pinIndex = pinIndex;
}



// UIViewController Basic Methods -----------------------//

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Navi Pop Gesture 활성화
    [self.navigationController.interactivePopGestureRecognizer setDelegate:self];
    
    
    //collectionView size
    CGFloat itemWidth = self.collectionView.frame.size.width / 3.0f;
    NSLog(@"itemWidth %f", itemWidth);
    
    self.flowLayout.itemSize = CGSizeMake(100, 100);
    // collectionView 임시 contents
    self.dataTempArr = @[@"addPost", @"textPhoto", @"Zion", @"Arches", @"Kenai Fjords", @"Mesa Verde", @"North Cascades", @"Great Sand Dunes"];
    
    
    
    // Map 세팅
    [self mapPreViewSetting];
    
    // Pin 세팅
    self.pinName.text = self.mapData.map_pin_list[self.pinIndex].pin_name;
    
    // User UI, 정보 세팅
    self.userProfileImage.layer.cornerRadius = self.userProfileImage.frame.size.width/2;
    self.userProfileImage.image = [[DataCenter sharedInstance].momoUserData getUserProfileImage];
    self.userNameToMade.text = [DataCenter sharedInstance].momoUserData.user_username;
    
    

}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [GoogleAnalyticsModule startGoogleAnalyticsTrackingWithScreenName:@"PinViewController"];
    
    // 네비바 숨기기
    [self.navigationController setNavigationBarHidden:YES];
    [self.view layoutIfNeeded];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    // 네비바 다시 노출
    [self.navigationController setNavigationBarHidden:NO];
    [self.view layoutIfNeeded];
}


// Map Setting Methods -------------------//

- (void)mapPreViewSetting {
    
    self.mapPreView.myLocationEnabled = YES;   // 내 위치 나타냄

    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.mapData.map_pin_list[self.pinIndex].pin_place.place_lat
                                                            longitude:self.mapData.map_pin_list[self.pinIndex].pin_place.place_lng
                                                                 zoom:15.0f];
    
    [self.mapPreView setCamera:camera];    // 핀 중심으로 카메라 설정
    
    
    // 마커찍기
    for (NSInteger i=0 ; i < self.mapData.map_pin_list.count ; i++) {
        GMSMarker *marker = [[GMSMarker alloc] init];
        
        marker.position = CLLocationCoordinate2DMake(self.mapData.map_pin_list[i].pin_place.place_lat, self.mapData.map_pin_list[i].pin_place.place_lng);

        PinMarkerUIView *pinMarkerView;

        if (i == self.pinIndex) {
            pinMarkerView = [[PinMarkerUIView alloc] initWithPinData:self.mapData.map_pin_list[i] withZoomCase:PIN_MARKER_DETAIL];
        } else {
            pinMarkerView = [[PinMarkerUIView alloc] initWithPinData:self.mapData.map_pin_list[i] withZoomCase:PIN_MARKER_CIRCLE];
        }
        marker.iconView = pinMarkerView;
        marker.map = self.mapPreView;
    }
}


// UICollectionViewDataSource Methods -------------------//

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.dataTempArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    PinContentsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    [cell.contentsBtn setImage:[UIImage imageNamed:self.dataTempArr[indexPath.row]] forState:UIControlStateNormal];
    [cell.contentsBtn setTag:indexPath.row];
    
    return cell;
}


// UICollectionViewDelegateFlowLayout Methods -----------//

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        return CGSizeMake(66, 100);
    } else {
        return CGSizeMake(100, 100);
    }
}


// Btn Action Methods -----------------------------------//

- (IBAction)selectedContentsBtnAction:(UIButton *)sender {
    
    NSLog(@"버튼 눌림 tag = %ld", sender.tag);
    
    if (sender.tag == 0) {
//        PinModificationViewController *pinModiVC = [[PinModificationViewController alloc] init];
        
//        PinModificationViewController *pinModiVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PinModificationViewController"];
//        [self.navigationController pushViewController:pinModiVC animated:YES];
        
        [self performSegueWithIdentifier:@"pinModiSegue" sender:self];
        
    } else {
        
        NSLog(@"pin post selected");
        
        [self performSegueWithIdentifier:@"pinDetailSegue" sender:self];
    }
}


//- (void)inputImageData:(NSString *)data {
//
//    self.contentImageView.image = [UIImage imageNamed:@"Katmai"];
//
//}


- (IBAction)backBtnAction:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}




@end
