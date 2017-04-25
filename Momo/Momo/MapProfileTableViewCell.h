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

- (void)initWithMapIndex:(NSInteger)mapIndex;
@property (nonatomic) NSInteger mapIndex;

@property (weak, nonatomic) id<MapProfileTableViewCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIView *backView;

@property (weak, nonatomic) IBOutlet UIImageView *userImgView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet UIImageView *mapPlaceholderImgView;
@property (weak, nonatomic) IBOutlet UIButton *mapNameBtn;
@property (weak, nonatomic) IBOutlet UILabel *mapPinNumLabel;

@property (weak, nonatomic) IBOutlet UIButton *mapEditBtn;


@property (weak, nonatomic) IBOutlet UIButton *labelBtnView;
@property (weak, nonatomic) IBOutlet UIButton *postBtnView;

@end



// 델리게이트 프로토콜 ----------------------------//

@protocol MapProfileTableViewCellDelegate <NSObject>

- (void)showSelectedMapAndMakePin:(MomoMapDataSet *)mapData;    // 해당 지도 보기 & 핀 생성 유도
- (void)showSelectedPin:(MomoPinDataSet *)pinData;      // 핀 보기
- (void)showSelectedPost:(MomoPostDataSet *)postData;   // 포스트 보기

- (void)selectedMapEditBtnWithIndex:(NSInteger)index;   // 지도 수정

@end

