//
//  MapViewController.m
//  Momo
//
//  Created by Jeheon Choi on 2017. 3. 27..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import "MapViewController.h"
#import "PinMarkerUIView.h"
#import "PinViewController.h"

#import "MapMakeViewController.h"

@interface MapViewController () <GMSMapViewDelegate>

@property (weak, nonatomic) IBOutlet GMSMapView *mapView;

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) NSInteger currentZoomCase;

@property (nonatomic) UISearchController *searchController;


// 롱 프레스 새 핀 생성, 등록
@property (nonatomic) BOOL isMakingMarker;
@property (nonatomic) BOOL isDragingMarker;
@property (nonatomic) GMSMarker *makingMarker;

@property (weak, nonatomic) IBOutlet UIView *makingMarkerBtnView;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;

// 선택 지도 보기
@property (nonatomic) BOOL showSelectedMap;

@property (nonatomic) MomoMapDataSet *mapData;
@property (weak, nonatomic) IBOutlet UIView *mapInfoView;
@property (weak, nonatomic) IBOutlet UIButton *mapInfoViewNameBtn;
@property (weak, nonatomic) IBOutlet UILabel *mapInfoViewDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *mapInfoViewPinNumLabel;
@property (weak, nonatomic) IBOutlet UIButton *mapInfoViewBtn;

@end



@implementation MapViewController

#pragma mark - ViewController Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // MapViewController 공통 기능 기본 세팅
    [self initialSetting];
    [self initialSettingGoogleMapView];
    
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [GoogleAnalyticsModule startGoogleAnalyticsTrackingWithScreenName:@"MapViewController"];
    NSLog(@"MapViewController : viewWillAppear");
    
    // 다른뷰 갔다가 와도 다시 Refresh될 수 있게 viewWillAppear에서 호출
    if (self.showSelectedMap) {
        // 선택 지도 보기 세팅
        [self mapInfoViewSetting];
        
    } else {
        // 사용자 모든 핀 보기
        self.mapData = [[MomoMapDataSet alloc] init];
        [self.mapData.map_pin_list addObjects:[MomoPinDataSet allObjects]];
    }
    
    [self markPinMarkersWithAnimation:NO];      // 마커찍기
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    //    NSLog(@"viewDidLayoutSubviews");
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //    NSLog(@"MapViewController : viewDidAppear");
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [(MainTabBarController *)self.tabBarController customTabBarSetHidden:NO];      // 탭바 Hidden 해제
    [self.view layoutIfNeeded];
}


- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}


#pragma mark - Show Selected Map Mode Methods

// 선택 지도 보기 세팅
- (void)showSelectedMapAndSetMapData:(MomoMapDataSet *)mapData {
    NSLog(@"showSelectedMapAndSetMapIndex : %@", mapData.map_name);
    
    self.showSelectedMap = YES;
    self.mapData = mapData;
}

// 선택 지도뷰 세팅
- (void)mapInfoViewSetting {
    
    // 정보 세팅
    [self.mapInfoViewNameBtn setTitle:self.mapData.map_name forState:UIControlStateNormal];
    if (self.mapData.map_is_private) {  // 비밀지도일때 자물쇠 아이콘 추가
        [self.mapInfoViewNameBtn setImage:[UIImage imageNamed:@"lockBtnClose"] forState:UIControlStateNormal];
        [self.mapInfoViewNameBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [self.mapInfoViewNameBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 2.5f, 0, 0)];
    }
    
    self.mapInfoViewDescriptionLabel.text = self.mapData.map_description;
    self.mapInfoViewPinNumLabel.text = [NSString stringWithFormat:@"%ld", self.mapData.map_pin_list.count];
    
    // 수정하기 (팔로워/팔로잉) 버튼
    [self.mapInfoViewBtn.layer setCornerRadius:12];
    [self.mapInfoViewBtn.layer setBorderColor:[UIColor mm_warmGreyColor].CGColor];
    [self.mapInfoViewBtn.layer setBorderWidth:1];
    
    // 선택지도보기 뷰 띄우기
    [self.view bringSubviewToFront:self.mapInfoView];
    [self.mapInfoView setHidden:NO];
    
    [self.view layoutIfNeeded];     // 지도 설명 길어졌을 때, View Height 달라짐
    self.mapView.padding = UIEdgeInsetsMake(20, 0, 49 + self.mapInfoView.frame.size.height, 0);

}

#pragma mark - Initial Setting Methods

// MapViewController 초기 세팅 ----------------------------//

- (void)initialSetting {
    
    // 새 핀 만들기 뷰의 버튼 UI세팅
    self.cancelBtn.layer.cornerRadius = 20;
    self.cancelBtn.layer.borderWidth = 1;
    self.cancelBtn.layer.borderColor = self.cancelBtn.titleLabel.textColor.CGColor;
    
    self.nextBtn.layer.cornerRadius = 20;
    self.nextBtn.layer.borderWidth = 1;
    self.nextBtn.layer.borderColor = self.nextBtn.backgroundColor.CGColor;

}


// GoogleMaps 관련 --------------------------------------//

// Google Map View 관련 객체 생성 및 초기설정
- (void)initialSettingGoogleMapView {
    
    self.mapView.padding = UIEdgeInsetsMake(20, 0, 49, 0);
    
    // 내 위치 정보
    self.mapView.myLocationEnabled = YES;
    self.mapView.settings.myLocationButton = YES;
    
    // 나침반 설정
    self.mapView.settings.compassButton = YES;
    
    // 내 위치를 중심으로 Map 띄우기
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        while([self.mapView myLocation].coordinate.latitude == 0.0f);   // 내 위치 받아오기까지 조금 시간 걸림
        
        dispatch_async(dispatch_get_main_queue(), ^{
//            NSLog(@"%f, %f", [self.mapView myLocation].coordinate.latitude, [self.mapView myLocation].coordinate.longitude);
            
            GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[self.mapView myLocation].coordinate.latitude
                                                                    longitude:[self.mapView myLocation].coordinate.longitude
                                                                         zoom:13.5f];
            
            [self.mapView setCamera:camera];    // 내 위치 중심으로 카메라 설정
        });
    });
    
    self.currentZoomCase = PIN_MARKER_DETAIL;
    
}



#pragma mark - Custom Methods

- (void)markPinMarkersWithAnimation:(BOOL)withAnimation {

    [self.mapView clear];
    
    // 등록된 핀
    for (NSInteger i=0 ; i < self.mapData.map_pin_list.count ; i++) {
        GMSMarker *marker = [[GMSMarker alloc] init];
        
        marker.position = CLLocationCoordinate2DMake(self.mapData.map_pin_list[i].pin_place.place_lat, self.mapData.map_pin_list[i].pin_place.place_lng);
        if (withAnimation) {
            marker.appearAnimation = kGMSMarkerAnimationPop;
        }
        PinMarkerUIView *pinMarkerView = [[PinMarkerUIView alloc] initWithPinData:self.mapData.map_pin_list[i] withZoomCase:self.currentZoomCase];
        marker.iconView = pinMarkerView;
        marker.map = self.mapView;
        
        marker.iconView.tag = i;
    }
    
    // 생성 중인 핀 마커
    if (self.isMakingMarker) {
        self.makingMarker.map = self.mapView;
    }
}



#pragma mark - GMSMapViewDelegate Methods

- (void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position {
//    NSLog(@"didChangeCameraPosition");
    
    NSInteger zoomCase;
    
    if(position.zoom > 13) {
        zoomCase = PIN_MARKER_DETAIL;
    } else if (position.zoom > 11) {
        zoomCase = PIN_MARKER_CIRCLE;
    } else {
        zoomCase = PIN_MARKER_SMALL_CIRCLE;
    }
    
    if (self.currentZoomCase != zoomCase) {
        self.currentZoomCase = zoomCase;
        [self markPinMarkersWithAnimation:YES];      // 마커찍기
    }
}




// 탭 제스쳐, 핀마커 상세 보기
- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    NSLog(@"didTapMarker");
    
    if (!self.isMakingMarker) {
        // 핀마커 등록 중엔 상세 보기 페이지 이동 불가
        
        UIStoryboard *pinViewStoryBoard = [UIStoryboard storyboardWithName:@"PinView" bundle:nil];
        PinViewController *pinVC = [pinViewStoryBoard instantiateInitialViewController];
        
        
        // 핀 데이터 세팅
        [pinVC showSelectedPinAndSetMapData:self.mapData withPinIndex:marker.iconView.tag];        
        [self.navigationController pushViewController:pinVC animated:YES];
        
    }
    
    return YES;
}


// 롱 프레스 새 핀마커 생성, 등록
- (void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinatee {
    NSLog(@"didLongPressAtCoordinate, isMakingMarker:%d", self.isMakingMarker);
    
    if (!self.isDragingMarker) {
        // 마커 드래그 아닐 때, 새 핀마커 생성 (하나씩만 만들 수 있게)
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = coordinatee;
        marker.icon = [UIImage imageNamed:@"tabPinS"];
        marker.draggable = YES;     // 드래그 가능
        
        self.isMakingMarker = YES;  // 핀 마커 만드는 중
        
        self.makingMarker.map = nil;    // 이전 만들던 마커 삭제
        self.makingMarker = marker;     // 새롭게 만드는 마커 프로퍼티에 셋
        
        marker.map = mapView;       // 마커 지도에 찍기

        
        // 위치등록 버튼 노출
        [self.makingMarkerBtnView setHidden:NO];

        [(MainTabBarController *)self.tabBarController customTabBarSetHidden:YES];      // 탭바 Hidden

        if (self.showSelectedMap) {
            // 선택지도 보기 상황
            [self.mapInfoView setHidden:YES];
            self.mapView.padding = UIEdgeInsetsMake(20, 0, 49, 0);
        }
        
        [self.view layoutIfNeeded];                 // 탭바 뺀, Constraints 다시 적용
        [self.view bringSubviewToFront:self.makingMarkerBtnView];       // Google Map View가 맨 앞으로 올라가는 현상 때문에 호출
    }
}


// 핀 만들기
- (void)makePinByMakePinBtn {
    // 내 위치를 중심으로 Map 띄우기
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        while([self.mapView myLocation].coordinate.latitude == 0.0f);   // 내 위치 받아오기까지 조금 시간 걸림
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"%f, %f", [self.mapView myLocation].coordinate.latitude, [self.mapView myLocation].coordinate.longitude);
            
            GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[self.mapView myLocation].coordinate.latitude
                                                                    longitude:[self.mapView myLocation].coordinate.longitude
                                                                         zoom:16.0f];
            [self.mapView animateWithCameraUpdate:[GMSCameraUpdate setCamera:camera]];    // 내 위치 중심으로 카메라 설정
            [self mapView:(GMSMapView *)self.view didLongPressAtCoordinate:[self.mapView myLocation].coordinate];       // 마지막 내 위치로 마커찍기
        });
    });
}


// 드래그 시작
- (void)mapView:(GMSMapView *)mapView didBeginDraggingMarker:(GMSMarker *)marker {
    self.isDragingMarker = YES;
}
// 종료
- (void)mapView:(GMSMapView *)mapView didEndDraggingMarker:(GMSMarker *)marker {
    self.isDragingMarker = NO;
}




#pragma mark - IBAction(UIButton) Methods
// IBAction(버튼) 메소드 ------------------------------------//

// 핀 만들기 취소 버튼 액션
- (IBAction)cancelBtnAction:(id)sender {
    NSLog(@"cancelBtnAction");
    
    // 위치등록 버튼 노출
    self.makingMarker.map = nil;
    self.isMakingMarker = NO;
    
    [self.makingMarkerBtnView setHidden:YES];
    [(MainTabBarController *)self.tabBarController customTabBarSetHidden:NO];
    
    if (self.showSelectedMap) {
        // 선택지도 보기 상황
        [self.mapInfoView setHidden:NO];
        self.mapView.padding = UIEdgeInsetsMake(20, 0, 49 + self.mapInfoView.frame.size.height, 0);
    }
}

// 핀 만들기 다음 버튼 액션
- (IBAction)nextBtnAction:(id)sender {
    
    UIStoryboard *makeStoryBoard = [UIStoryboard storyboardWithName:@"Make" bundle:nil];
    UIViewController *pinMakeVC = [makeStoryBoard instantiateViewControllerWithIdentifier:@"PinMakeViewController"];
    
    [self.navigationController pushViewController:pinMakeVC animated:YES];
    
}


// 선택지도 수정/팔로우 버튼 액션
- (IBAction)mapInfoViewBtnAction:(id)sender {
    // 선택 지도 수정
    UIStoryboard *makeStoryBoard = [UIStoryboard storyboardWithName:@"Make" bundle:nil];
    MapMakeViewController *mapMakeVC = [makeStoryBoard instantiateViewControllerWithIdentifier:@"MapMakeViewController"];
    
    [mapMakeVC setEditModeWithMapData:self.mapData];   // 수정 모드, 데이터 세팅
    [self.navigationController pushViewController:mapMakeVC animated:YES];

    
}

@end
