//
//  PostTableViewHeaderView.h
//  Momo
//
//  Created by Jeheon Choi on 2017. 4. 26..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PostTableViewHeaderViewDelegate;

@interface PostTableViewHeaderView : UITableViewHeaderFooterView

@property (weak, nonatomic) id<PostTableViewHeaderViewDelegate> delegate;

@end



@protocol PostTableViewHeaderViewDelegate <NSObject>

- (void)backBtnAction;

- (void)addPostBtnAction;

@end
