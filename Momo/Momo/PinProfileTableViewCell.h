//
//  PinProfileTableViewCell.h
//  Momo
//
//  Created by Jeheon Choi on 2017. 4. 6..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PinProfileTableViewCellDelegate;


@interface PinProfileTableViewCell : UITableViewCell

- (void)initWithPinIndex:(NSInteger)pinIndex;
@property (nonatomic) NSInteger pinIndex;

@property (weak, nonatomic) id<PinProfileTableViewCellDelegate> delegate;


@property (weak, nonatomic) IBOutlet UIView *backView;

@property (weak, nonatomic) IBOutlet GMSMapView *mapView;

@property (weak, nonatomic) IBOutlet UILabel *pinNameLabel;

@property (weak, nonatomic) IBOutlet UIImageView *userImgView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

@property (weak, nonatomic) IBOutlet UIButton *pinEditBtn;

@end



// 델리게이트 프로토콜 ----------------------------//
@protocol PinProfileTableViewCellDelegate <NSObject>

- (void)selectedPinEditBtnWithIndex:(NSInteger)index;

@end
