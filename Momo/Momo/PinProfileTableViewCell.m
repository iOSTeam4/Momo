//
//  PinProfileTableViewCell.m
//  Momo
//
//  Created by Jeheon Choi on 2017. 4. 6..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import "PinProfileTableViewCell.h"
#import "PinMarkerView.h"

@interface PinProfileTableViewCell ()

@property (nonatomic) MomoPinDataSet *pinData;

@end


@implementation PinProfileTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
//    NSLog(@"awakeFromNib");
}


- (void)initWithPinData:(MomoPinDataSet *)pinData {
    
    // 데이터 세팅
    self.pinData = pinData;
    
    // 유저 프사
    if (self.pinData.pin_author.profile_img_data) {
        self.userImgView.image  = [self.pinData.pin_author getAuthorProfileImg];
    }
    
    // 유저 이름
    self.userNameLabel.text = self.pinData.pin_author.username;
    
    // 핀 제목
    self.pinNameLabel.text = self.pinData.pin_name;
    
}


- (void)layoutSubviews {
    [super layoutSubviews];
//    NSLog(@"layoutSubviews");
    
    // 프로필 BackView 세팅
    self.backView.layer.shadowOffset = CGSizeMake(-5, 8);
    self.backView.layer.shadowRadius = 10;
    self.backView.layer.shadowOpacity = 0.3;
    
    // 프로필 사진 동그랗게
    [self.userImgView.layer setCornerRadius:self.userImgView.frame.size.height/2];
    
    // 수정하기 버튼
    [self.pinEditBtn.layer setCornerRadius:12];
    [self.pinEditBtn.layer setBorderColor:[UIColor mm_warmGreyColor].CGColor];
    [self.pinEditBtn.layer setBorderWidth:1];
    
    // 전체 Cell Frame 설정
    self.backView.frame = CGRectMake(self.backView.frame.origin.x, self.backView.frame.origin.y, self.backView.frame.size.width, self.pinEditBtn.frame.origin.y + self.pinEditBtn.frame.size.height + 10);
    
    // 맵에 핀 표기
    [self mapViewSetting];
    
}

- (void)mapViewSetting {
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.pinData.pin_place.place_lat
                                                            longitude:self.pinData.pin_place.place_lng
                                                                 zoom:16.0f];
    
    [self.mapView setCamera:camera];    // 핀 중심으로 카메라 설정
    
    
    // 현재 보고있는 핀만 마커찍기
    [self.mapView clear];    // 기존 마커 삭제
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.groundAnchor = CGPointMake(0.5, 0.6);        // 마커가 지도 중앙 위치에 놓일 수 있게 설정 (중앙 약간 위)
    
    marker.position = CLLocationCoordinate2DMake(self.pinData.pin_place.place_lat, self.pinData.pin_place.place_lng);
    
    PinMarkerView *pinMarkerView = [[PinMarkerView alloc] initWithPinData:self.pinData withZoomCase:PIN_MARKER_PIN_VIEW_CIRCLE];
    
    marker.icon = [pinMarkerView imageFromViewForMarker];
    marker.map = self.mapView;
    
}


- (IBAction)pinEditBtnAction:(id)sender {
    NSLog(@"pinEditBtnAction");
    [self.delegate selectedPinEditBtnWithPinData:self.pinData];
}

@end
