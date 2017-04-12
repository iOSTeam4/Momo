//
//  PinMarkerUIView.h
//  Momo
//
//  Created by Jeheon Choi on 2017. 3. 29..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import <UIKit/UIKit.h>

// Pin Marker 관련
#define PIN_MARKER_DETAIL 0
#define PIN_MARKER_CIRCLE 1
#define PIN_MARKER_SMALL_CIRCLE 2

// PIN_MARKER_DETAIL
#define PIN_MARKER_DETAIL_HEIGHT       35.f
#define PIN_MARKER_DETAIL_WIDTH_MARGIN 15.f
#define PIN_MARKER_DETAIL_FONT_SIZE    14.f
#define PIN_MARKER_DETAIL_FONT         [UIFont boldSystemFontOfSize:PIN_MARKER_DETAIL_FONT_SIZE]

// CIRCLE & SMALL_CIRCLE
#define PIN_MARKER_CIRCLE_SIZE             25.f
#define PIN_MARKER_SMALL_CIRCLE_SIZE       10.f

#define PIN_MARKER_ICON_IMAGE_MARGIN       10.f


@interface PinMarkerUIView : UIView

// 반드시 이 메소드로 init할 것!
- (instancetype)initWithPinData:(MomoPinDataSet *)pinData withZoomCase:(NSInteger)zoomCase;

@end
