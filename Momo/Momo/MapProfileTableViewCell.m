//
//  MapProfileTableViewCell.m
//  Momo
//
//  Created by Jeheon Choi on 2017. 4. 6..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import "MapProfileTableViewCell.h"
#import "PinMarkerUIView.h"

@implementation MapProfileTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
}

- (void)initWithMapIndex:(NSInteger)mapIndex {

    // 데이터 세팅
    
    self.mapIndex = mapIndex;       // 지도 마커 표시를 위해 mapIndex 프로퍼티에 셋
    
    // 프사
    if ([DataCenter sharedInstance].momoUserData.user_profile_image_data) {
        self.userImgView.image  = [[DataCenter sharedInstance].momoUserData getUserProfileImage];
    }
    
    // 이름
    if ([DataCenter sharedInstance].momoUserData.user_username) {
        self.userNameLabel.text = [DataCenter sharedInstance].momoUserData.user_username;
    }
    
    // 맵 제목
    [self.mapNameBtn setTitle:[DataCenter myMapList][mapIndex].map_name forState:UIControlStateNormal];
    
    // 비밀지도일때 자물쇠 아이콘 추가
    if ([DataCenter myMapList][mapIndex].map_is_private) {
        [self.mapNameBtn setImage:[UIImage imageNamed:@"lockBtnClose"] forState:UIControlStateNormal];
        [self.mapNameBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [self.mapNameBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 2.5, 0, 0)];
    }
    
    // 맵 속의 핀 갯수
    self.mapPinNumLabel.text = [NSString stringWithFormat:@"%ld", [DataCenter myMapList][mapIndex].map_pin_list.count];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
//    NSLog(@"layoutSubviews");
    
    // 프로필 BackView 세팅
//    [self.backView.layer setCornerRadius:20];
    self.backView.layer.shadowOffset = CGSizeMake(-5, 8);
    self.backView.layer.shadowRadius = 10;
    self.backView.layer.shadowOpacity = 0.3;
    
    // 프로필 사진 동그랗게
    [self.userImgView.layer setCornerRadius:self.userImgView.frame.size.height/2];
//    NSLog(@"cell width : %f , userImgView.frame.size.height/2 : %f", self.frame.size.width, self.userImgView.frame.size.height/2);
    
    // 수정하기 버튼
    [self.mapEditBtn.layer setCornerRadius:5];
    [self.mapEditBtn.layer setBorderColor:[UIColor mm_warmGreyColor].CGColor];
    [self.mapEditBtn.layer setBorderWidth:1];
    
    // 전체 Cell Frame 설정
    self.backView.frame = CGRectMake(self.backView.frame.origin.x, self.backView.frame.origin.y, self.backView.frame.size.width, self.mapEditBtn.frame.origin.y + self.mapEditBtn.frame.size.height + 10);
    
    
    // 카메라 이동, 마커 찍기
    [self mapViewSetting];
}

- (void)mapViewSetting {

    [self bringSubviewToFront:self.mapPlaceholderImgView];
    
    // Google Map View 설정
    if ([DataCenter myPinListWithMapIndex:self.mapIndex].count > 0) {
        self.mapPlaceholderImgView.alpha = 0.0f;    // mapPlaceholderImgView 가리기
        
        // Cell Reuse 할 때, 기존 마커 Clear
        [self.mapView clear];
        
        
        // 최초 min, max에 0번 핀 값 넣음
        CLLocationCoordinate2D minCoordinate = CLLocationCoordinate2DMake([DataCenter myPinListWithMapIndex:self.mapIndex][0].pin_place.place_lat, [DataCenter myPinListWithMapIndex:self.mapIndex][0].pin_place.place_lng);
        CLLocationCoordinate2D maxCoordinate = CLLocationCoordinate2DMake([DataCenter myPinListWithMapIndex:self.mapIndex][0].pin_place.place_lat, [DataCenter myPinListWithMapIndex:self.mapIndex][0].pin_place.place_lng);
        
        for (MomoPinDataSet *pinData in [DataCenter myPinListWithMapIndex:self.mapIndex]) {
            
            // pin marker 찍기
            GMSMarker *marker = [[GMSMarker alloc] init];
            
            marker.position = CLLocationCoordinate2DMake(pinData.pin_place.place_lat, pinData.pin_place.place_lng);
            marker.appearAnimation = kGMSMarkerAnimationPop;
            
            PinMarkerUIView *pinMarkerView = [[PinMarkerUIView alloc] initWithPinData:pinData withZoomCase:PIN_MARKER_CIRCLE];
            marker.iconView = pinMarkerView;
            marker.map = self.mapView;
            
            
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
        
//        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:37.572456f
//                                                                longitude:126.976851f
//                                                                     zoom:7.0f];
//
//        [self.mapView setCamera:camera];    // 카메라 초기 위치 세팅 (광화문)
        
        
        GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:minCoordinate coordinate:maxCoordinate];
        GMSCameraPosition *camera = [self.mapView cameraForBounds:bounds insets:UIEdgeInsetsMake(20, 20, 20, 20)];
        
        [self.mapView setCamera:camera];      // 카메라 최종 위치로 이동
        
    } else {
        
        self.mapPlaceholderImgView.alpha = 1.0f;    // mapPlaceholderImgView 띄우기
        
    }
}


- (IBAction)mapEditBtnAction:(id)sender {
    NSLog(@"mapEditBtnAction");
    [self.delegate selectedMapEditBtnWithIndex:self.tag];
}

@end
