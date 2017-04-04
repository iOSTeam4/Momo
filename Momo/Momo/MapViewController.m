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


@interface MapViewController () <GMSMapViewDelegate>

@property (weak, nonatomic) IBOutlet GMSMapView *mapView;

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) NSInteger currentZoomCase;


// 롱 프레스 새 핀 생성, 등록
@property (nonatomic) BOOL isMakingMarker;
@property (nonatomic) BOOL isDragingMarker;
@property (nonatomic) GMSMarker *makingMarker;

@property (weak, nonatomic) IBOutlet UIView *makingMarkerBtnView;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;

@end



@implementation MapViewController

#pragma mark - ViewController Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initialSetting];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];    
    [GoogleAnalyticsModule startGoogleAnalyticsTrackingWithScreenName:@"MapViewController"];
    NSLog(@"MapViewController : viewWillAppear");

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"MapViewController : viewDidAppear");
    
}



#pragma mark - Initial Setting Methods


// MapViewController 초기 세팅 ----------------------------//

- (void)initialSetting {
    [self.navigationItem setTitle:@"Map View"];
    
    [self initialSetGoogleMapView];
    
    self.makingMarkerBtnView.layer.borderWidth = 0.25f;
    self.makingMarkerBtnView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    
    self.cancelBtn.layer.cornerRadius = 10;
    self.cancelBtn.layer.borderWidth = 1;
    self.cancelBtn.layer.borderColor = self.cancelBtn.titleLabel.textColor.CGColor;
    
    self.nextBtn.layer.cornerRadius = 10;
    self.nextBtn.layer.borderWidth = 1;
    self.nextBtn.layer.borderColor = self.nextBtn.backgroundColor.CGColor;
}


// GoogleMaps 관련 --------------------------------------//

// Google Map View 관련 객체 생성 및 초기설정
- (void)initialSetGoogleMapView {
    
    self.mapView.padding = UIEdgeInsetsMake(64, 0, 49, 0);
    
    // 내 위치 정보
    self.mapView.myLocationEnabled = YES;
    self.mapView.settings.myLocationButton = YES;
    
    // 나침반 설정
    self.mapView.settings.compassButton = YES;
    
    // 내 위치를 중심으로 Map 띄우기
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        while([self.mapView myLocation].coordinate.latitude == 0.0f);   // 내 위치 받아오기까지 조금 시간 걸림
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"%f, %f", [self.mapView myLocation].coordinate.latitude, [self.mapView myLocation].coordinate.longitude);
            
            GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[self.mapView myLocation].coordinate.latitude
                                                                    longitude:[self.mapView myLocation].coordinate.longitude
                                                                         zoom:13.5f];
            
            [self.mapView setCamera:camera];    // 내 위치 중심으로 설정
        });
    });
    
    self.currentZoomCase = PIN_MARKER_DETAIL;
    [self markPinMarkers];      // 마커찍기
    
}

#pragma mark - Custom Methods

- (void)markPinMarkers {
    
    for (NSArray *arr in [DataCenter sharedInstance].locationArr) {
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = CLLocationCoordinate2DMake([arr[0] doubleValue], [arr[1] doubleValue]);
        marker.title = arr[2];
        marker.snippet = arr[2];
        marker.infoWindowAnchor = CGPointMake(0.5f, 0.0f);
        marker.appearAnimation = kGMSMarkerAnimationPop;
        
        PinMarkerUIView *pinMarkerView = [[PinMarkerUIView alloc] initWithArr:arr withZoomCase:self.currentZoomCase];
        marker.icon = [pinMarkerView imageFromViewForMarker];
        marker.map = self.mapView;
    }
    
    if (self.isMakingMarker) {
        self.makingMarker.map = self.mapView;
    }
}



#pragma mark - GMSMapViewDelegate Methods

- (void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position {
    NSLog(@"didChangeCameraPosition");
    
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
        [mapView clear];
        [self markPinMarkers];      // 마커찍기
    }
}

- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position {
    NSLog(@"idleAtCameraPosition");
    
}


//- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker {
//
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
//    [view setBackgroundColor:[UIColor grayColor]];
//
//    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [btn setTitle:@"마커마커" forState:UIControlStateNormal];
//    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [btn.titleLabel setAdjustsFontSizeToFitWidth:YES];
//    [view addSubview:btn];
//
//    btn.frame = CGRectMake(10, 0, 30, 30);
//
//    UILabel *lb = [[UILabel alloc] init];
//    [view addSubview:lb];
//    lb.frame = CGRectMake(50, 0, 40, 30);
//    lb.text = @"이게 바로 마커인가?";
//    lb.textColor = [UIColor blueColor];
//    [lb setAdjustsFontSizeToFitWidth:YES];
//    [lb setBackgroundColor:[UIColor purpleColor]];
//
//    return view;
//}



// 탭 제스쳐, 핀마커 상세 보기
- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    NSLog(@"didTapMarker");
    
    if (!self.isMakingMarker) {
        // 핀마커 등록 중엔 상세 보기 페이지 이동 불가
        
        [self.tabBarController.tabBar setHidden:NO];
        
        UIStoryboard *pinViewStoryBoard = [UIStoryboard storyboardWithName:@"PinView" bundle:nil];
        PinViewController *pinVC = [pinViewStoryBoard instantiateInitialViewController];
        
        [self.navigationController pushViewController:pinVC animated:YES];
        pinVC.navigationItem.title = marker.title;
    }
    
    return YES;
}


// 롱 프레스 새 핀마커 생성, 등록
- (void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinatee {
    NSLog(@"didLongPressAtCoordinate, isDragingMarker:%d, makingMarker:%d", self.isDragingMarker, self.isMakingMarker);
    
    if (!self.isDragingMarker) {
        // 기존 새 핀마커를 롱클릭하여 드래깅하고 있는 상황이 아닐 때, 새 핀마커 생성 (하나씩만 만들 수 있게)
        
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = coordinatee;
        marker.infoWindowAnchor = CGPointMake(0.5f, 0.0f);
        marker.draggable = YES;
        
        marker.map = mapView;
        self.isMakingMarker = YES;  // 핀 마커 만드는 중
        
        self.makingMarker.map = nil;    // 이전 만들던 마커 삭제
        self.makingMarker = marker;     // 새롭게 만드는 마커 프로퍼티에 셋
        
        // 위치등록 버튼 노출
        [self.tabBarController.tabBar setHidden:YES];
        [self.view layoutIfNeeded];                 // 탭바 뺀, Constraints 다시 적용
        [self.makingMarkerBtnView setHidden:NO];
        [self.view bringSubviewToFront:self.makingMarkerBtnView];       // Google Map View가 맨 앞으로 올라감
    }
}


// 롱 프레스 새 핀마커 이동
- (void)mapView:(GMSMapView *)mapView didBeginDraggingMarker:(GMSMarker *)marker {
    NSLog(@"didBeginDraggingMarker");
    
    self.isDragingMarker = YES;
}

// 엣지 부분으로 핀마커 드래그 했을 때, 맵 이동
// 제스쳐로 처리해야 부드럽게 잘 될 것임.
// 이건 실패 ㅠㅠ.. 꼭 지우고 다시 새롭게 적용할 것, 일단 우선순위에서 밀리는 추가 기능이므로 skip
- (void)mapView:(GMSMapView *)mapView didDragMarker:(GMSMarker *)marker {
    
    NSLog(@"height %f", self.view.frame.size.height);
    NSLog(@"didDragMarker mapView.frame.size : %f, %f  markerframe : %f, %f, %f, %f", mapView.frame.size.width, mapView.frame.size.height, marker.accessibilityFrame.origin.x, marker.accessibilityFrame.origin.y, marker.accessibilityFrame.size.width, marker.accessibilityFrame.size.height);
    
    CGFloat moveX = 0;
    CGFloat moveY = 0;
    
    if (marker.accessibilityFrame.origin.x < 50) {
        NSLog(@"x left < 50");
        
        moveX = -50;
        
    } else if (mapView.frame.size.width - marker.accessibilityFrame.origin.x < 50) {
        NSLog(@"x right < 50, %f", mapView.frame.size.width - marker.accessibilityFrame.origin.x);
        
        moveX = 50;
    }
    
    if (marker.accessibilityFrame.origin.y < 50) {
        NSLog(@"y left < 50");
        
        moveY = -50;
        
    } else if (mapView.frame.size.height - 113 - marker.accessibilityFrame.origin.y < 50) {
        NSLog(@"y right < 50, %f", mapView.frame.size.height - 113 - marker.accessibilityFrame.origin.y);
        
        moveY = 50;
    }

    [mapView animateWithCameraUpdate:[GMSCameraUpdate scrollByX:moveX Y:moveY]];
}

- (void)mapView:(GMSMapView *)mapView didEndDraggingMarker:(GMSMarker *)marker {
    NSLog(@"didEndDraggingMarker");
    
    self.isDragingMarker = NO;
}



#pragma mark - IBAction(UIButton) Methods
// IBAction(버튼) 메소드 ------------------------------------//

- (IBAction)cancelBtnAction:(id)sender {
    NSLog(@"cancelBtnAction");
    
    // 위치등록 버튼 노출
    self.makingMarker.map = nil;
    self.isMakingMarker = NO;
    
    [self.makingMarkerBtnView setHidden:YES];
    [self.tabBarController.tabBar setHidden:NO];
}


- (IBAction)nextBtnAction:(id)sender {
    
}


@end
