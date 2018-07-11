//
//  PinMakeViewController.h
//  Momo
//
//  Created by Hanson Jung on 2017. 4. 4..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PinMakeViewController : UIViewController

// 선택 지도보기에서 핀 생성으로 이동했을 때
- (void)wasSelectedMap:(BOOL)wasSelectedMapView
             withMapPK:(NSInteger)selectedMap_pk;

- (void)setLat:(CGFloat)lat
       withLng:(CGFloat)lng;

- (void)setEditModeWithPinData:(MomoPinDataSet *)pinData;
@property BOOL wasPinView;      // 핀뷰에서 수정했는지?

@end
