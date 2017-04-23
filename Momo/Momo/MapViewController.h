//
//  MapViewController.h
//  Momo
//
//  Created by Jeheon Choi on 2017. 3. 27..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapViewController : UIViewController

- (void)makePinByMakePinBtn;    // 새 핀 만들기 버튼로 새 핀 생성시 호출하는 메서드

// 선택지도 보기, 지도 데이터 세팅
- (void)showSelectedMapAndSetMapData:(MomoMapDataSet *)mapData;

// 선택지도 보기, 지도, 중심 핀 데이터 세팅
- (void)showSelectedMapAndSetMapData:(MomoMapDataSet *)mapData
                 withFocusingPinData:(MomoPinDataSet *)pinData;

// 새 핀 생성 완성 후 부르는 메서드
- (void)successCreatePin;

@end
