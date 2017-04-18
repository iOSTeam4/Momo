//
//  TextCell.h
//  Momo
//
//  Created by Hanson Jung on 2017. 4. 17..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import <UIKit/UIKit.h>

#define PROFILE_HEIGHT 20
#define MATTBAR_HEIGHT 50
#define HEADER_MARGIN 20
#define FOOTER_MARGIN 20


@protocol TextCellDelegate;

@interface TextCell : UITableViewCell

@property (nonatomic) id<TextCellDelegate> delegate;
- (void)setContentsWithIndexPath:(NSIndexPath *)indexPath;

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView3;
@property (weak, nonatomic) IBOutlet UILabel *userName3;
@property (weak, nonatomic) IBOutlet UIImageView *categoryImg3;
@property (weak, nonatomic) IBOutlet UILabel *pinName3;
@property (weak, nonatomic) IBOutlet UILabel *pinAddress3;
@property (weak, nonatomic) IBOutlet UILabel *pinMainText3;

@end




@protocol TextCellDelegate <NSObject>

@optional
- (void)contextHeight:(CGFloat)cellHeight hasImg:(BOOL)hasImg;

@end



