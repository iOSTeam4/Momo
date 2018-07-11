//
//  GoogleAnalyticsModule.h
//  Momo
//
//  Created by Jeheon Choi on 2017. 4. 3..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GoogleAnalyticsModule : NSObject

+ (void)startGoogleAnalyticsTrackingWithScreenName:(NSString *)screenName;

@end
