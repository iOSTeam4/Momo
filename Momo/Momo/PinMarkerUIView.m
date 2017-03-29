//
//  PinMarkerUIView.m
//  Momo
//
//  Created by Jeheon Choi on 2017. 3. 29..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import "PinMarkerUIView.h"

#define PIN_MARKER_DETAIL_HEIGHT       24.f
#define PIN_MARKER_DETAIL_WIDTH_MARGIN 24.f
#define PIN_MARKER_DETAIL_FONT_SIZE    11.f
#define PIN_MARKER_DETAIL_FONT         [UIFont boldSystemFontOfSize:PIN_MARKER_DETAIL_FONT_SIZE]

#define PIN_MARKER_CIRCLE_SIZE             18.f
#define PIN_MARKER_SMALL_CIRCLE_SIZE       10.f


@interface PinMarkerUIView ()

@property (nonatomic) NSArray *arr;     // 더미 데이터 어레이 (테스트용)

@property (nonatomic) const CGFloat *colorComponents;
@property (nonatomic) NSInteger zoomCase;

@end


@implementation PinMarkerUIView


// 반드시 이 메소드로 init
- (instancetype)initWithArr:(NSArray *)arr withZoomCase:(NSInteger)zoomCase {
    self = [super init];
    
    if (self) {
        self.arr = arr;
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
            CGSize pinMarkerInfoSize = [(NSString *)self.arr[2] sizeWithAttributes:@{NSFontAttributeName:PIN_MARKER_DETAIL_FONT}];
            CGFloat pinMarkerWidth = pinMarkerInfoSize.width + PIN_MARKER_DETAIL_WIDTH_MARGIN;

            self.frame = CGRectMake(0, 0, pinMarkerWidth, PIN_MARKER_DETAIL_HEIGHT);
            
            break;
        }
        case PIN_MARKER_CIRCLE: {
            self.frame = CGRectMake(0, 0, PIN_MARKER_CIRCLE_SIZE, PIN_MARKER_CIRCLE_SIZE);
            
            break;
        }
        default: {      // PIN_MARKER_SMALL_CIRCLE
            self.frame = CGRectMake(0, 0, PIN_MARKER_SMALL_CIRCLE_SIZE, PIN_MARKER_SMALL_CIRCLE_SIZE);
            
            break;
        }
    }
}


// RGB 추출 메소드
- (void)setColorComponents {
    _colorComponents = CGColorGetComponents([(UIColor *)self.arr[3] CGColor]);     // Alpha는 무조건 1
//    NSLog(@"Red: %f",   _colorComponents[0]);
//    NSLog(@"Green: %f", _colorComponents[1]);
//    NSLog(@"Blue: %f",  _colorComponents[2]);
}


// Override drawRect method
- (void)drawRect:(CGRect)rect {
    NSLog(@"@Override drawRect method -> PinMarker view");
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
            
            CGFloat ratio = 0.75f;       // PinMarkerInfo : PinMarkerTail = ratio : (1-ratio)
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
    [btn setTitle:_arr[2] forState:UIControlStateDisabled];
    [btn.titleLabel setFont:PIN_MARKER_DETAIL_FONT];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 4, 0, 0)];

    // ImageView (icon)
    FAKFontAwesome *icon = self.arr[4];
    [icon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    UIImage *iconImg = [icon imageWithSize:CGSizeMake(rect.size.height-8, rect.size.height-8)];
    
    [btn setImage:iconImg forState:UIControlStateDisabled];
    [btn.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [btn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 4)];

    // Set InfoBtn BackgroundColor
    [btn setBackgroundColor:[UIColor colorWithRed:_colorComponents[0] green:_colorComponents[1] blue:_colorComponents[2] alpha:1]];

}

// Zoom Case 1 : PIN_MARKER_CIRCLE

- (void)setPinMarkerZoomCaseOne {
    
    // ImageView (icon)
    FAKFontAwesome *icon = self.arr[4];
    [icon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    UIImage *iconImg = [icon imageWithSize:CGSizeMake(self.frame.size.width-8, self.frame.size.height-8)];
    
    UIImageView *iconimgView = [[UIImageView alloc] initWithImage:iconImg];
    [iconimgView setContentMode:UIViewContentModeScaleAspectFit];
    iconimgView.frame = CGRectMake(4, 4, self.frame.size.width-8, self.frame.size.height-8);
    
    [self addSubview:iconimgView];
}



// UIView to UIImage ---------------------------------------//

- (UIImage *)imageFromViewForMarker {
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, [[UIScreen mainScreen] scale]);
    } else {
        UIGraphicsBeginImageContext(self.frame.size);
    }
    [self.layer renderInContext: UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}


@end
