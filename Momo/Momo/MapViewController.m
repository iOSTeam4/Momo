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
#import "PinMakeViewController.h"


#define SELECTED_MAP_MODE            1
#define SELECTED_MAP_MODE_WITH_PIN   2


@interface MapViewController () <GMSMapViewDelegate, UIGestureRecognizerDelegate>

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
@property (nonatomic) NSInteger showSelectedMap;
@property (nonatomic) MomoPinDataSet *pinData;
@property (nonatomic) GMSMarker *focusingPinMarker;

@property (nonatomic) MomoMapDataSet *mapData;
@property (weak, nonatomic) IBOutlet UIView *mapInfoView;
@property (weak, nonatomic) IBOutlet UIButton *mapInfoViewNameBtn;
@property (weak, nonatomic) IBOutlet UILabel *mapInfoViewDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *mapInfoViewPinNumLabel;
@property (weak, nonatomic) IBOutlet UIButton *mapInfoViewBtn;

@end



@implementation MapViewController


- (void)successCreatePin {
    self.isMakingMarker = NO;
}



#pragma mark - ViewController Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Navi Pop Gesture 활성화, 아래 gestureRecognizerShouldBegin와 세트
    [self.navigationController.interactivePopGestureRecognizer setDelegate:self];

    
    // MapViewController 공통 기능 기본 세팅
    [self initialSetting];
    [self initialSettingGoogleMapView];
    
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [GoogleAnalyticsModule startGoogleAnalyticsTrackingWithScreenName:@"MapViewController"];
    NSLog(@"MapViewController : viewWillAppear");
    
    // 다른뷰 갔다가 와도 다시 Refresh될 수 있게 viewWillAppear에서 호출
    
    if (self.isMakingMarker) {
        // 핀 마커 만들기 중, 뒤로 돌아왔을 때
        [self.makingMarkerBtnView setHidden:NO];            // 위치등록 버튼 노출
        
        [(MainTabBarController *)self.tabBarController customTabBarSetHidden:YES];      // 탭바 Hidden
        
        if (self.showSelectedMap) {
            // 선택지도 보기 상황
            [self.mapInfoView setHidden:YES];
            self.mapView.padding = UIEdgeInsetsMake(20, 0, 49, 0);
        }
        
        [self.view layoutIfNeeded];                                     // 탭바 뺀, Constraints 다시 적용
        [self.view bringSubviewToFront:self.makingMarkerBtnView];       // Google Map View가 맨 앞으로 올라가는 현상 때문에 호출
    
        
    } else if (self.showSelectedMap) {          // SELECTED_MAP_MODE or SELECTED_MAP_MODE_WITH_PIN
        // 선택지도 보기
        [self mapInfoViewSetting];
        
    } else {
        // 사용자 모든 핀 보기 (default)
        self.mapData = [[MomoMapDataSet alloc] init];
        for (MomoMapDataSet *mapData in [DataCenter myMapList]) {
            [self.mapData.map_pin_list addObjects:mapData.map_pin_list];
        }
    }
    
    [self markPinMarkersWithAnimation:NO];      // 마커찍기
    
    
    // 선택 핀 중심으로 이동, (선택지도 보기)
    if (self.showSelectedMap == SELECTED_MAP_MODE_WITH_PIN) {
    
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{

            sleep(1);       // 1초 후 이동
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"선택 핀을 중심으로 카메라 이동");
                
                GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.focusingPinMarker.position.latitude
                                                                        longitude:self.focusingPinMarker.position.longitude
                                                                             zoom:13.5f];
                [CATransaction begin];
                [CATransaction setValue:[NSNumber numberWithFloat: 2.0f] forKey:kCATransactionAnimationDuration];
                
                [self.mapView animateWithCameraUpdate:[GMSCameraUpdate setCamera:camera]];    // 선택된 핀 중심으로 카메라 이동
                
                [CATransaction commit];
            });
        });
    }
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [(MainTabBarController *)self.tabBarController customTabBarSetHidden:NO];      // 탭바 Hidden 해제
    [self.view layoutIfNeeded];
}


// NaviBar Hidden 상황 & PopGestureRecognizer 사용 예외처리
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    NSLog(@"MyViewController : gestureRecognizerShouldBegin, %ld", self.navigationController.viewControllers.count);
    
    // NaviController RootViewController에서는 PopGesture 실행 안되도록 처리
    if(self.navigationController.viewControllers.count > 1){
        return YES;
    }
    return NO;
}



#pragma mark - Show Selected Map Mode Methods

// 선택지도 보기 세팅
- (void)showSelectedMapAndSetMapData:(MomoMapDataSet *)mapData {
    NSLog(@"showSelectedMapAndSetMapData : %@", mapData.map_name);
    
    self.showSelectedMap = SELECTED_MAP_MODE;
    self.mapData = mapData;
}

// 선택지도 보기, 지도, 중심 핀 데이터 세팅
- (void)showSelectedMapAndSetMapData:(MomoMapDataSet *)mapData
                 withFocusingPinData:(MomoPinDataSet *)pinData {
    NSLog(@"showSelectedMapAndSetMapData : %@ withFocusingPinData : %@", mapData.map_name, pinData.pin_name);
    
    self.showSelectedMap = SELECTED_MAP_MODE_WITH_PIN;
    self.mapData = mapData;
    self.pinData = pinData;
}


// 선택지도 뷰 세팅
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
    
    
    // 사용자 모든 핀 보기 & 비어있는 선택지도 보기
    if (!self.showSelectedMap || (self.mapData.map_pin_list.count == 0)) {
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
        
    } else {
        // 선택지도 핀 보기
        
        // 최초 min, max에 0번 핀 값 넣음
        CLLocationCoordinate2D minCoordinate = CLLocationCoordinate2DMake(self.mapData.map_pin_list[0].pin_place.place_lat, self.mapData.map_pin_list[0].pin_place.place_lng);
        CLLocationCoordinate2D maxCoordinate = CLLocationCoordinate2DMake(self.mapData.map_pin_list[0].pin_place.place_lat, self.mapData.map_pin_list[0].pin_place.place_lng);
        
        for (MomoPinDataSet *pinData in self.mapData.map_pin_list) {
            
            // find min, max latitude
            if (pinData.pin_place.place_lat < minCoordinate.latitude) {
                
                minCoordinate.latitude = pinData.pin_place.place_lat;
                
            } else if (pinData.pin_place.place_lat > maxCoordinate.latitude) {
                
                maxCoordinate.latitude = pinData.pin_place.place_lat;
            }
            
            // find min, max longitude
            if (pinData.pin_place.place_lng < minCoordinate.longitude) {
                
                minCoordinate.longitude = pinData.pin_place.place_lng;
                
            } else if (pinData.pin_place.place_lng > maxCoordinate.longitude) {
                
                maxCoordinate.longitude = pinData.pin_place.place_lng;
            }
            
        }
        
        GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:minCoordinate coordinate:maxCoordinate];
        GMSCameraPosition *camera = [self.mapView cameraForBounds:bounds insets:UIEdgeInsetsMake(20, 20, 20, 20)];
        
        [self.mapView setCamera:camera];    // 선택지도, 핀들 전부 보이는 위치로 이동
        
    }
    
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
        
        if (self.showSelectedMap == SELECTED_MAP_MODE_WITH_PIN) {
            if (i == [self.mapData.map_pin_list indexOfObject:self.pinData]) {
                self.focusingPinMarker = marker;            // 중심에 놓을 핀 마커 프로퍼티에 세팅
            }
        }
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
    
    if(position.zoom > 12) {
        zoomCase = PIN_MARKER_DETAIL;
    } else if (position.zoom > 8) {
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
        [pinVC showSelectedPinAndSetPinData:self.mapData.map_pin_list[marker.iconView.tag]];        
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
        marker.icon = [UIImage imageNamed:@"mapPinS"];
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
    PinMakeViewController *pinMakeVC = [makeStoryBoard instantiateViewControllerWithIdentifier:@"PinMakeViewController"];
    
    [pinMakeVC setLat:self.makingMarker.position.latitude
              withLng:self.makingMarker.position.longitude];
    
    [self presentViewController:pinMakeVC animated:YES completion:nil];
}


// 선택지도 수정/팔로우 버튼 액션
- (IBAction)mapInfoViewBtnAction:(id)sender {
    // 선택 지도 수정
    UIStoryboard *makeStoryBoard = [UIStoryboard storyboardWithName:@"Make" bundle:nil];
    MapMakeViewController *mapMakeVC = [makeStoryBoard instantiateViewControllerWithIdentifier:@"MapMakeViewController"];
    
    [mapMakeVC setEditModeWithMapData:self.mapData];   // 수정 모드, 데이터 세팅
    [self presentViewController:mapMakeVC animated:YES completion:nil];

}

@end
