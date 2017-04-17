//
//  GoogleAnalyticsModule.m
//  Momo
//
//  Created by Jeheon Choi on 2017. 4. 3..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import "GoogleAnalyticsModule.h"

@implementation GoogleAnalyticsModule


+ (void)startGoogleAnalyticsTrackingWithScreenName:(NSString *)screenName {

    NSString *name = [NSString stringWithFormat:@"Pattern~%@", screenName];
    
    // The UA-XXXXX-Y tracker ID is loaded automatically from the
    // GoogleService-Info.plist by the `GGLContext` in the AppDelegate.
    // If you're copying this to an app just using Analytics, you'll
    // need to configure your tracking ID here.
    // [START screen_view_hit_objc]
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker set:kGAIScreenName value:name];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    // [END screen_view_hit_objc]
}
    
@end
