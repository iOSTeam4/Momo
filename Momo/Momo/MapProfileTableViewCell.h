//
//  MapProfileTableViewCell.h
//  Momo
//
//  Created by Jeheon Choi on 2017. 4. 6..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MapProfileTableViewCellDelegate;


@interface MapProfileTableViewCell : UITableViewCell

@property (weak, nonatomic) id<MapProfileTableViewCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIView *backView;

@property (weak, nonatomic) IBOutlet UIImageView *userImgView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *mapNameBtn;
@property (weak, nonatomic) IBOutlet UILabel *mapPinNumLabel;

@property (weak, nonatomic) IBOutlet UIButton *mapEditBtn;

@end



// 델리게이트 프로토콜 ----------------------------//

@protocol MapProfileTableViewCellDelegate <NSObject>

- (void)selectedMapEditBtnWithIndex:(NSInteger)index;

@end

