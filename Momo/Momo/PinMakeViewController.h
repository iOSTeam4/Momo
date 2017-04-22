//
//  PinMakeViewController.h
//  Momo
//
//  Created by Hanson Jung on 2017. 4. 4..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PinMakeViewController : UIViewController

- (void)setLat:(CGFloat)lat
       withLng:(CGFloat)lng;

- (void)setEditModeWithPinData:(MomoPinDataSet *)pinData;

@end
