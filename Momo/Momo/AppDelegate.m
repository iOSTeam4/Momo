//
//  AppDelegate.m
//  Momo
//
//  Created by Jeheon Choi on 2017. 3. 27..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // App 전체 tint 컬러 적용
    [self.window setTintColor:[UIColor mm_brightSkyBlueColor]];
    
    // Google Analytics
    [self googleAnalyticsTrackerStart];
    
    // GoogleMaps & GooglePlaces API Key Setting
    [GMSServices provideAPIKey:GOOGLE_API_KEY];
    [GMSPlacesClient provideAPIKey:GOOGLE_API_KEY];
    
    
    // Facebook API
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];

    return YES;
}



- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    // Facebook Analytics for Apps https://www.facebook.com/analytics/
    [FBSDKAppEvents activateApp];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
//    if ([DataCenter getUserToken] != nil) {
//        [DataCenter saveMomoUserData];     // 앱 종료 전 데이터 DB에 저장
//    }
}
    
    
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

- (void)googleAnalyticsTrackerStart {
    // [START tracker_objc]
    // Configure tracker from GoogleService-Info.plist.
    NSError *configureError;
    [[GGLContext sharedInstance] configureWithError:&configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    
    // Optional: configure GAI options.
    GAI *gai = [GAI sharedInstance];
    gai.trackUncaughtExceptions = YES;  // report uncaught exceptions
    gai.logger.logLevel = kGAILogLevelVerbose;  // remove before app release
    // [END tracker_objc]
}

@end
