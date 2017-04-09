//
//  UIPlaceHolderTextView.h
//  Momo
//
//  Created by Jeheon Choi on 2017. 4. 10..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//
// http://stackoverflow.com/questions/1328638/placeholder-in-uitextview?page=1&tab=votes#tab-top

#import <Foundation/Foundation.h>

IB_DESIGNABLE
@interface UIPlaceHolderTextView : UITextView

@property (nonatomic, retain) IBInspectable NSString *placeholder;
@property (nonatomic, retain) IBInspectable UIColor *placeholderColor;

-(void)textChanged:(NSNotification*)notification;

@end
