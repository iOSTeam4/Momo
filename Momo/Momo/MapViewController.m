//
//  MapViewController.m
//  Momo
//
//  Created by Jeheon Choi on 2017. 3. 27..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController ()

@end

@implementation MapViewController {
    GMSMapView *_mapView;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initialSetting];
}



// MapViewController 초기 세팅 ----------------------------//

- (void)initialSetting {
    [self.navigationItem setTitle:@"Map View"];
    
    [self createAndInitialSetGoogleMapView];
}


// GoogleMaps 관련 --------------------------------------//

// Google Map View 관련 객체 생성 및 초기설정
- (void)createAndInitialSetGoogleMapView {
    

    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:37.515697
                                                            longitude:127.021370
                                                                 zoom:10];
    
    CGRect mapFrame = CONTENT_VIEW_FRAME_WITHOUT_TABBAR_AND_NAVIBAR;
    _mapView = [GMSMapView mapWithFrame:mapFrame camera:camera];
    
    _mapView.myLocationEnabled = YES;
    [self.view addSubview:_mapView];
    
    // Creates a marker in the center of the map.
    for (NSArray *arr in [DataCenter sharedInstance].locationArr) {
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = CLLocationCoordinate2DMake([arr[0] doubleValue], [arr[1] doubleValue]);
        marker.map = _mapView;
    }
}


@end
