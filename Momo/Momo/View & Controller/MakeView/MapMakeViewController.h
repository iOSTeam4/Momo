//
//  MapMakeViewController.h
//  Momo
//
//  Created by Hanson Jung on 2017. 4. 6..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapMakeViewController : UIViewController

- (void)setEditModeWithMapData:(MomoMapDataSet *)mapData;
@property (nonatomic) BOOL wasMapView;      // 맵뷰에서 수정했는지?

@end
