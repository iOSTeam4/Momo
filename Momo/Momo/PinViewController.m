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
#import "PinMakeViewController.h"


@interface PinViewController ()
<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate>

@property (nonatomic) MomoMapDataSet *mapData;  // 접근한 지도 데이터
@property (nonatomic) NSInteger pinIndex;       // 핀 데이터 인덱스

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;
@property (weak, nonatomic) IBOutlet GMSMapView *mapPreView;
@property (weak, nonatomic) IBOutlet UIButton *mapPreViewBtn;

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
    
    //collectionView size
    CGFloat itemWidth = self.collectionView.frame.size.width / 3.0f;
    NSLog(@"itemWidth %f", itemWidth);
    
    self.flowLayout.itemSize = CGSizeMake(100, 100);

    // collectionView 임시 contents
    self.dataTempArr = @[@"addPost", @"textPhoto", @"Zion", @"Arches", @"Kenai Fjords", @"Mesa Verde", @"North Cascades", @"Great Sand Dunes"];

    //collectionView shadow
    self.collectionView.layer.shadowOffset = CGSizeMake(-5, 15);
    self.collectionView.layer.shadowRadius = 10;
    self.collectionView.layer.shadowOpacity = 0.3;
    self.collectionView.layer.masksToBounds = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [GoogleAnalyticsModule startGoogleAnalyticsTrackingWithScreenName:@"PinViewController"];
        
    // Navi Pop Gesture 활성화
    [self.navigationController.interactivePopGestureRecognizer setDelegate:self];

    // Map 세팅
    [self mapPreViewSetting];
    
    // Pin 세팅
    self.pinName.text = self.mapData.map_pin_list[self.pinIndex].pin_name;
    self.pinAddress.text = self.mapData.map_pin_list[self.pinIndex].pin_place.place_address;
    self.pinMainText.text = self.mapData.map_pin_list[self.pinIndex].pin_description;
    
    // User UI, 정보 세팅
    self.userProfileImage.layer.cornerRadius = self.userProfileImage.frame.size.width/2;
    self.userProfileImage.image = [[DataCenter sharedInstance].momoUserData getUserProfileImage];
    self.userNameToMade.text = [DataCenter sharedInstance].momoUserData.user_username;

}



- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}


// Map Setting Methods -------------------//

- (void)mapPreViewSetting {
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.mapData.map_pin_list[self.pinIndex].pin_place.place_lat
                                                            longitude:self.mapData.map_pin_list[self.pinIndex].pin_place.place_lng
                                                                 zoom:16.0f];
    
    [self.mapPreView setCamera:camera];    // 핀 중심으로 카메라 설정
    

    // 현재 보고있는 핀만 마커찍기
    [self.mapPreView clear];    // 기존 마커 삭제
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.groundAnchor = CGPointMake(0.5, 0.6);        // 마커가 지도 중앙 위치에 놓일 수 있게 설정 (중앙 약간 위)
    
    marker.position = CLLocationCoordinate2DMake(self.mapData.map_pin_list[self.pinIndex].pin_place.place_lat, self.mapData.map_pin_list[self.pinIndex].pin_place.place_lng);
    
    PinMarkerUIView *pinMarkerView = [[PinMarkerUIView alloc] initWithPinData:self.mapData.map_pin_list[self.pinIndex] withZoomCase:PIN_MARKER_PIN_VIEW_CIRCLE];

    marker.iconView = pinMarkerView;
    marker.map = self.mapPreView;
    
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
        return CGSizeMake(66, 100); // 추가버튼
        
        
        
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




- (IBAction)editBtnAction:(id)sender {
    NSLog(@"editBtnAction");
 
    // 핀 수정
    UIStoryboard *makeStoryBoard = [UIStoryboard storyboardWithName:@"Make" bundle:nil];
    PinMakeViewController *pinMakeVC = [makeStoryBoard instantiateViewControllerWithIdentifier:@"PinMakeViewController"];
    
    [pinMakeVC setEditModeWithPinData:self.mapData.map_pin_list[self.pinIndex]];   // 수정 모드, 데이터 세팅
    [self.navigationController pushViewController:pinMakeVC animated:YES];
}

- (IBAction)backBtnAction:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}




@end
