//
//  PinMarkerUIView.m
//  Momo
//
//  Created by Jeheon Choi on 2017. 3. 29..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import "PinMarkerUIView.h"

@interface PinMarkerUIView ()

@property (nonatomic) MomoPinDataSet *pinData;

@property (nonatomic) const CGFloat *colorComponents;
@property (nonatomic) NSInteger zoomCase;

@end


@implementation PinMarkerUIView


// 반드시 이 메소드로 init
- (instancetype)initWithPinData:(MomoPinDataSet *)pinData withZoomCase:(NSInteger)zoomCase {
    self = [super init];
    
    if (self) {
        self.pinData = pinData;
        self.zoomCase = zoomCase;
        
        [self setFrameWithZoomCase];
        [self setColorComponents];      // RGB 추출
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}



// 기본 세팅 커스텀 메소드 --------------------------------------//


// ZoomCase에 따라 다르게 Frame 설정
- (void)setFrameWithZoomCase {
    switch (self.zoomCase) {
        case PIN_MARKER_DETAIL: {
            CGSize pinMarkerInfoSize = [self.pinData.pin_name sizeWithAttributes:@{NSFontAttributeName:PIN_MARKER_DETAIL_FONT}];
            CGFloat pinMarkerWidth = pinMarkerInfoSize.width + PIN_MARKER_DETAIL_WIDTH_MARGIN;

            self.frame = CGRectMake(0, 0, pinMarkerWidth, PIN_MARKER_DETAIL_HEIGHT);
            
            break;
        }
        case PIN_MARKER_CIRCLE: {
            self.frame = CGRectMake(0, 0, PIN_MARKER_CIRCLE_SIZE, PIN_MARKER_CIRCLE_SIZE);
            
            break;
        }
        case PIN_MARKER_SMALL_CIRCLE: {
            self.frame = CGRectMake(0, 0, PIN_MARKER_SMALL_CIRCLE_SIZE, PIN_MARKER_SMALL_CIRCLE_SIZE);
            break;
        }
        default: {      // PIN_MARKER_SMALL_CIRCLE
            self.frame = CGRectMake(0, 0, PIN_MARKER_PIN_VIEW_CIRCLE_SIZE, PIN_MARKER_PIN_VIEW_CIRCLE_SIZE);
            
            break;
        }
    }
}


// RGB 추출 메소드
- (void)setColorComponents {
    self.colorComponents = CGColorGetComponents([[self.pinData labelColor] CGColor]);     // Alpha는 무조건 1
//    NSLog(@"Pin name : %@, Label : %ld", self.pinData.pin_name, self.pinData.pin_label);
//    NSLog(@"Red: %.5f, Green: %.5f, Blue: %.5f",   _colorComponents[0], _colorComponents[1], _colorComponents[2]);
}


// Override drawRect method
- (void)drawRect:(CGRect)rect {
//    NSLog(@"@Override drawRect method -> PinMarker view");
    /* PinMarker
        
     // zoomCase 0 : PIN_MARKER_DETAIL -------------------//
       _____________
      (____info_____)   <- PinMarkerInfo
            \/          <- PinMarkerTail
     
    
     info의 좌우 커브, 작은img, Label은 눌리지 않는 버튼 위에 덮어씌움
     
     
     // zoomCase 1 : PIN_MARKER_CIRCLE -------------------//
     
     원 속에 아이콘들어있는 형태, 백그라운드 컬러 적용

     
     // zoomCase 2 : PIN_MARKER_SMALL_CIRCLE -------------//
     
     작은 원, 백그라운드 컬러 적용
     
 
    */
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    switch (self.zoomCase) {
        case PIN_MARKER_DETAIL: {
            
            CGFloat ratio = 0.8f;       // PinMarkerInfo : PinMarkerTail = ratio : (1-ratio)
            CGFloat pinMarkerInfoMaxY = CGRectGetMinY(rect) + CGRectGetHeight(rect)*ratio;
            
            CGFloat pinMarkerInfoMinX = CGRectGetMinX(rect) + CGRectGetHeight(rect)*ratio/2.f;
            CGFloat pinMarkerInfoMaxX = CGRectGetMaxX(rect) - CGRectGetHeight(rect)*ratio/2.f;
            
            CGFloat pinMarkerTailMinX = CGRectGetMidX(rect) - CGRectGetMaxY(rect)*(1.f-ratio)*sqrt(2)/2.f;
            CGFloat pinMarkerTailMaxX = CGRectGetMidX(rect) + CGRectGetMaxY(rect)*(1.f-ratio)*sqrt(2)/2.f;
            
            CGContextBeginPath(ctx);
            CGContextMoveToPoint   (ctx, pinMarkerInfoMinX, CGRectGetMinY(rect));   // top left
            CGContextAddLineToPoint(ctx, pinMarkerInfoMaxX, CGRectGetMinY(rect));   // top right
            CGContextAddLineToPoint(ctx, pinMarkerInfoMaxX, pinMarkerInfoMaxY);     // mid right
            CGContextAddLineToPoint(ctx, pinMarkerTailMaxX, pinMarkerInfoMaxY);                 // mid mid+
            CGContextAddLineToPoint(ctx, CGRectGetMidX(rect), CGRectGetMaxY(rect));             // btm mid
            CGContextAddLineToPoint(ctx, pinMarkerTailMinX, pinMarkerInfoMaxY);                 // mid mid-
            CGContextAddLineToPoint(ctx, pinMarkerInfoMinX, pinMarkerInfoMaxY);     // mid left
            CGContextClosePath(ctx);
            
            CGContextSetRGBFillColor(ctx, _colorComponents[0], _colorComponents[1], _colorComponents[2], 1);
            CGContextFillPath(ctx);
            
            [self setPinMarkerInfoZoomCaseZeroWithFrame:CGRectMake(CGRectGetMinX(rect), CGRectGetMinY(rect), CGRectGetWidth(rect), CGRectGetHeight(rect)*ratio)];
            
            break;
        }
        case PIN_MARKER_CIRCLE:
        case PIN_MARKER_PIN_VIEW_CIRCLE:
            [self setPinMarkerZoomCaseOne];
            
        default: {    // PIN_MARKER_CIRCLE & PIN_MARKER_SMALL_CIRCLE
            
            CGFloat lineWidth = 2;
            CGRect borderRect = CGRectInset(rect, lineWidth * 0.5, lineWidth * 0.5);

            CGContextSetRGBFillColor(ctx, _colorComponents[0], _colorComponents[1], _colorComponents[2], 1);
            CGContextSetRGBStrokeColor(ctx, 1, 1, 1, 1);
            CGContextSetLineWidth(ctx, 1);
            CGContextFillEllipseInRect (ctx, borderRect);
            CGContextStrokeEllipseInRect(ctx, borderRect);
            CGContextFillPath(ctx);
            
            break;
        }
    }
}



// Zoom Case Method ----------------------------------------//

// Zoom Case 0 : PIN_MARKER_DETAIL

- (void)setPinMarkerInfoZoomCaseZeroWithFrame:(CGRect)rect {
    
    // ImageView, Title, CornerRadius 설정 용이하게 하기위해 Btn사용
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setEnabled:NO];        // 버튼으로서 사용되진 않음
    btn.frame = rect;

    [self addSubview:btn];
    
    // ConerRadius
    btn.layer.cornerRadius = btn.frame.size.height/2.0f;
    
    // Title Label
    [btn setTitle:self.pinData.pin_name forState:UIControlStateDisabled];
    [btn.titleLabel setFont:PIN_MARKER_DETAIL_FONT];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
//    [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 4, 0, 0)];

//    // ImageView (icon)
//    [btn setImage:[self.pinData labelIcon] forState:UIControlStateDisabled];
//    [btn.imageView setContentMode:UIViewContentModeScaleAspectFit];
//    [btn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 4)];

    // Set InfoBtn BackgroundColor
    [btn setBackgroundColor:[UIColor colorWithRed:_colorComponents[0] green:_colorComponents[1] blue:_colorComponents[2] alpha:1]];

}

// Zoom Case 1 : PIN_MARKER_CIRCLE

- (void)setPinMarkerZoomCaseOne {
    
    // ImageView (icon)
    UIImageView *iconimgView = [[UIImageView alloc] initWithImage:[self labelIcon]];
    [iconimgView setContentMode:UIViewContentModeScaleAspectFit];
    
    if(self.zoomCase == PIN_MARKER_CIRCLE) {
        CGFloat iconSize = PIN_MARKER_CIRCLE_SIZE - PIN_MARKER_ICON_IMAGE_MARGIN;
        iconimgView.frame = CGRectMake(PIN_MARKER_ICON_IMAGE_MARGIN/2, PIN_MARKER_ICON_IMAGE_MARGIN/2, iconSize, iconSize);

    } else {
        CGFloat iconSize = PIN_MARKER_PIN_VIEW_CIRCLE_SIZE - PIN_MARKER_ICON_IMAGE_MARGIN * 2;
        iconimgView.frame = CGRectMake(PIN_MARKER_ICON_IMAGE_MARGIN, PIN_MARKER_ICON_IMAGE_MARGIN, iconSize, iconSize);

    }
    
    [self addSubview:iconimgView];
}


// 핀 라벨 아이콘
- (UIImage *)labelIcon {
    
    switch (self.pinData.pin_label) {
        case 0:
            return [UIImage imageNamed:@"0cafe"];
        case 1:
            return [UIImage imageNamed:@"1food"];
        case 2:
            return [UIImage imageNamed:@"2shop"];
        case 3:
            return [UIImage imageNamed:@"3place"];
        default:
            return [UIImage imageNamed:@"4etc"];
    }
    
}





@end
