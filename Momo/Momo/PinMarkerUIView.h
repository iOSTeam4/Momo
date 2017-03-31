//
//  PinMarkerUIView.h
//  Momo
//
//  Created by Jeheon Choi on 2017. 3. 29..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PinMarkerUIView : UIView

// 반드시 이 메소드로 init할 것!
- (instancetype)initWithArr:(NSArray *)arr withZoomCase:(NSInteger)zoomCase;     // 더미 데이터 어레이 (테스트용)


// UIView(모든 SubViews포함)를 UIImage로 변환시켜 반환하는 메소드
// GoogleMaps의 Marker 꼭 Image로 넣어줘야 함..
- (UIImage *)imageFromViewForMarker;

@end
