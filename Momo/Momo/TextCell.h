//
//  TextCell.h
//  Momo
//
//  Created by Hanson Jung on 2017. 4. 17..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TextCellDelegate;

@interface TextCell : UITableViewCell

@property (weak, nonatomic) id<TextCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView3;
@property (weak, nonatomic) IBOutlet UILabel *userName3;
@property (weak, nonatomic) IBOutlet UIButton *editBtn3;
@property (weak, nonatomic) IBOutlet UIView *categoryColorView3;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel3;
@property (weak, nonatomic) IBOutlet UILabel *pinName3;
@property (weak, nonatomic) IBOutlet UILabel *pinAddress3;
@property (weak, nonatomic) IBOutlet UILabel *pinMainText3;

@end


// 델리게이트 프로토콜 ----------------------------//

@protocol TextCellDelegate <NSObject>

- (void)editBtnAction:(NSInteger)index;

@end



