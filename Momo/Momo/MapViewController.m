//
//  MapViewController.m
//  Momo
//
//  Created by Jeheon Choi on 2017. 3. 27..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import "MapViewController.h"
#import "PinMarkerUIView.h"


@interface MapViewController () <GMSMapViewDelegate>

@property (nonatomic) GMSMapView *mapView;

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) NSInteger currentZoomCase;

@end



@implementation MapViewController

#pragma mark - ViewController Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initialSetting];
    
}



#pragma mark - Initial Setting Methods


// MapViewController 초기 세팅 ----------------------------//

- (void)initialSetting {
    [self.navigationItem setTitle:@"Map View"];
    
    [self createAndInitialSetGoogleMapView];
}


// GoogleMaps 관련 --------------------------------------//

// Google Map View 관련 객체 생성 및 초기설정
- (void)createAndInitialSetGoogleMapView {
    
    CGRect mapFrame = CONTENT_VIEW_FRAME_WITHOUT_TABBAR_AND_NAVIBAR;
    self.mapView = [[GMSMapView alloc] initWithFrame:mapFrame];
    self.mapView.delegate = self;
    
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
            [self.view addSubview:self.mapView];
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
}



#pragma mark - GMSMapViewDelegate Methods

- (void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position {

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



@end
