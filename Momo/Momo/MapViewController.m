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


@property (nonatomic) BOOL isMakingMarker;
@property (nonatomic) GMSMarker *makingMarker;
//@property (nonatomic) BOOL isDragingMarker;

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



- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    NSLog(@"didTapMarker");
    
    UIStoryboard *pinViewStoryBoard = [UIStoryboard storyboardWithName:@"PinView" bundle:nil];
    PinViewController *pinVC = [pinViewStoryBoard instantiateInitialViewController];
    
    [self.navigationController pushViewController:pinVC animated:YES];
    pinVC.navigationItem.title = marker.title;
    
    return YES;
}


// 지도 롱클릭해서 새 핀 등록
- (void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinatee {
    NSLog(@"didLongPressAtCoordinate, isDragingMarker:%d", self.isMakingMarker);
    
    if (!self.isMakingMarker) {
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = coordinatee;
        marker.infoWindowAnchor = CGPointMake(0.5f, 0.0f);
        marker.draggable = YES;
        
        marker.map = mapView;
        self.isMakingMarker = YES;  // 핀 마커 만드는 중 (하나씩만 만들 수 있게)
        self.makingMarker = marker;
        
        // 위치등록 버튼 노출
        [self.makingMarkerBtnView setHidden:NO];
        [self.tabBarController.tabBar setHidden:YES];
        [self.view bringSubviewToFront:self.makingMarkerBtnView];
    }
}


- (void)mapView:(GMSMapView *)mapView didBeginDraggingMarker:(GMSMarker *)marker {
    NSLog(@"didBeginDraggingMarker");
    
//    self.isDragingMarker = YES;
}

- (void)mapView:(GMSMapView *)mapView didEndDraggingMarker:(GMSMarker *)marker {
    NSLog(@"didEndDraggingMarker");

//    self.isDragingMarker = NO;
}

- (IBAction)cancelBtnAction:(id)sender {
    // 위치등록 버튼 노출
    self.makingMarker.map = nil;
    self.isMakingMarker = NO;
    [self.makingMarkerBtnView setHidden:YES];
    [self.tabBarController.tabBar setHidden:NO];
}


- (IBAction)nextBtnAction:(id)sender {
    
}


@end
