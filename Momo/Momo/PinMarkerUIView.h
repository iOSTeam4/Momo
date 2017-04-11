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

@end
