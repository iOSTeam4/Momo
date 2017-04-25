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
#import "MapViewController.h"

#import "PostMakeViewController.h"
#import "PinPostViewController.h"

#define POST_MAKE_BUTTON 0

@interface PinViewController ()
<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate>

@property (nonatomic) MomoPinDataSet *pinData;

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

- (void)showSelectedPinAndSetPinData:(MomoPinDataSet *)pinData {
    self.pinData = pinData;
}


// UIViewController Basic Methods -----------------------//

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 지도 위, 투명 버튼 셀렉터 메서드 세팅 (IBAction으로 바꿀 것)
    [self.mapPreViewBtn addTarget:self action:@selector(mapPreViewBtnAction) forControlEvents:UIControlEventTouchUpInside];
    
    //collectionView size
    CGFloat itemWidth = self.collectionView.frame.size.width / 3.0f;
    NSLog(@"itemWidth %f", itemWidth);
    
    self.flowLayout.itemSize = CGSizeMake(100, 100);

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
    
    // 반드시 컬렉션 뷰 refresh 해야함
    [self.collectionView reloadData];
    
    // Map 세팅
    [self mapPreViewSetting];
    
    // Pin 세팅
    self.pinName.text = self.pinData.pin_name;
    self.pinAddress.text = self.pinData.pin_place.place_address;
    self.pinMainText.text = self.pinData.pin_description;
    
    // User UI, 정보 세팅
    self.userProfileImage.layer.cornerRadius = self.userProfileImage.frame.size.width/2;
    self.userProfileImage.image = [[DataCenter sharedInstance].momoUserData getUserProfileImage];
    self.userNameToMade.text = [DataCenter sharedInstance].momoUserData.user_username;

}


// 지도 버튼 액션
- (void)mapPreViewBtnAction {
    // 선택 핀 중심으로 지도 보기
    UIStoryboard *makeStoryBoard = [UIStoryboard storyboardWithName:@"Map" bundle:nil];
    MapViewController *mapVC = [makeStoryBoard instantiateViewControllerWithIdentifier:@"MapViewController"];
    
    MomoMapDataSet *mapData = [DataCenter findMapDataWithMapPK:self.pinData.pin_map_pk];
    
    [mapVC showSelectedMapAndSetMapData:mapData
                    withFocusingPinData:self.pinData];
    
    [self.navigationController pushViewController:mapVC animated:YES];
}


// Map Setting Methods -------------------//

- (void)mapPreViewSetting {
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.pinData.pin_place.place_lat
                                                            longitude:self.pinData.pin_place.place_lng
                                                                 zoom:16.0f];
    
    [self.mapPreView setCamera:camera];    // 핀 중심으로 카메라 설정
    

    // 현재 보고있는 핀만 마커찍기
    [self.mapPreView clear];    // 기존 마커 삭제
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.groundAnchor = CGPointMake(0.5, 0.6);        // 마커가 지도 중앙 위치에 놓일 수 있게 설정 (중앙 약간 위)
    
    marker.position = CLLocationCoordinate2DMake(self.pinData.pin_place.place_lat, self.pinData.pin_place.place_lng);
    
    PinMarkerUIView *pinMarkerView = [[PinMarkerUIView alloc] initWithPinData:self.pinData withZoomCase:PIN_MARKER_PIN_VIEW_CIRCLE];

    marker.iconView = pinMarkerView;
    marker.map = self.mapPreView;
    
}



// UICollectionViewDataSource Methods -------------------//

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return 1 + self.pinData.pin_post_list.count;        // 작성버튼 + pin_post_list.count
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    PinContentsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.contentsBtn.tag = self.pinData.pin_post_list.count - indexPath.row;    // 가장 최신 포스트부터 나열하도록
    
    if (indexPath.row == POST_MAKE_BUTTON) {       // * 작성 버튼 때문에 실제 데이터는 row에 -1 씩 계산 필요함 *
        // 포스트 작성 버튼
        cell.contentsBtn.tag = -1;   // 예외적으로 다시 -1으로 할당
        
        [cell.contentsBtn setTitle:nil forState:UIControlStateNormal];  // 글 삭제 (초기화)
        
        [cell.contentsBtn setImage:[UIImage imageNamed:@"addPost"] forState:UIControlStateNormal];

    } else if ([self.pinData.pin_post_list[self.pinData.pin_post_list.count - indexPath.row] getPostPhoto]) {
        // 사진이 있는 경우
        [cell.contentsBtn setTitle:nil forState:UIControlStateNormal];  // 글 삭제 (초기화)

        [cell.contentsBtn setImage:[self.pinData.pin_post_list[self.pinData.pin_post_list.count - indexPath.row] getPostPhoto] forState:UIControlStateNormal];

    } else {
        // 글만 있는 경우
        [cell.contentsBtn setImage:nil forState:UIControlStateNormal];  // 사진 삭제 (초기화)
        
        [cell.contentsBtn setBackgroundColor:[UIColor whiteColor]];
        [cell.contentsBtn setTitle:self.pinData.pin_post_list[self.pinData.pin_post_list.count - indexPath.row].post_description forState:UIControlStateNormal];
        [cell.contentsBtn setTitleColor:[UIColor mm_brightSkyBlueColor] forState:UIControlStateNormal];
        [cell.contentsBtn.titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [cell.contentsBtn setTitleEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        [cell.contentsBtn.titleLabel setNumberOfLines:3];
    }
    
    return cell;
}


// UICollectionViewDelegateFlowLayout Methods -----------//

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == POST_MAKE_BUTTON) {
        return CGSizeMake(66, 100); // 추가버튼
        
    } else {
        return CGSizeMake(100, 100);
    }
}





// 각각의 Cell 속 Btn Action Method
- (IBAction)selectedContentsBtnAction:(UIButton *)sender {
    
    NSLog(@"버튼 눌림 tag = %ld", sender.tag);
    
    if (sender.tag == -1) {     // POST_MAKE_BUTTON 태그값은 -1

        // Make Post
        PostMakeViewController *postMakeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PostMakeViewController"];
        [postMakeVC setMakeModeWithPinPK:self.pinData.pk];      // pin_pk 전달해줘야 포스트 생성가능
        [self presentViewController:postMakeVC animated:YES completion:nil];
        
    } else {
        
        // Post View
        PinPostViewController *postVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PinPostViewController"];
        [postVC showSelectedPostAndSetPostData:self.pinData.pin_post_list[sender.tag]];
        [self.navigationController pushViewController:postVC animated:YES];
        
    }
}


- (IBAction)addPostBtnAction:(UIButton *)sender {
    NSLog(@"addPostBtnAction");
    
    // Make Post
    PostMakeViewController *postMakeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PostMakeViewController"];
    [postMakeVC setMakeModeWithPinPK:self.pinData.pk];      // pin_pk 전달해줘야 포스트 생성가능
    postMakeVC.wasPostView = YES;    // post뷰에서 이동
    [self presentViewController:postMakeVC animated:YES completion:nil];
    
}

- (IBAction)editBtnAction:(id)sender {
    NSLog(@"editBtnAction");
 
    // 핀 수정
    UIStoryboard *makeStoryBoard = [UIStoryboard storyboardWithName:@"Make" bundle:nil];
    PinMakeViewController *pinMakeVC = [makeStoryBoard instantiateViewControllerWithIdentifier:@"PinMakeViewController"];
    
    [pinMakeVC setEditModeWithPinData:self.pinData];   // 수정 모드, 데이터 세팅
    [self presentViewController:pinMakeVC animated:YES completion:nil];
}

- (IBAction)backBtnAction:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}




@end
