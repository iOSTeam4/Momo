//
//  NetworkModule.h
//  Momo
//
//  Created by Jeheon Choi on 2017. 3. 27..
//  Copyright © 2017년 JeheonChoi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkModule : NSObject

//********************************************************//
//                       Member API                       //
//********************************************************//

// E-mail account ---------------------------------//
#pragma mark - E-mail Auth Account Methods

// Sign Up
+ (void)signUpRequestWithUsername:(NSString *)username
                     withPassword:(NSString *)password
                        withEmail:(NSString *)email
              withCompletionBlock:(void (^)(BOOL isSuccess, NSString* result))completionBlock;

// Login
+ (void)loginRequestWithUsername:(NSString *)username
                    withPassword:(NSString *)password
             withCompletionBlock:(void (^)(BOOL isSuccess, NSString* result))completionBlock;




// Common ----------------------------------------//
#pragma mark - Account Common Methods
// Log Out
+ (void)logOutRequestWithCompletionBlock:(void (^)(BOOL isSuccess, NSString* result))completionBlock;
// Get member profile
+ (void)getMemberProfileRequestWithCompletionBlock:(void (^)(BOOL isSuccess, NSString* result))completionBlock;

// Patch member profile update
+ (void)patchMemberProfileUpdateWithUsername:(NSString *)username
                          withProfileImgData:(NSData *)imgData
                             withDescription:(NSString *)description
                         withCompletionBlock:(void (^)(BOOL isSuccess, NSString *result))completionBlock;


//********************************************************//
//                        Map API                         //
//********************************************************//


// Map Create
+ (void)createMapRequestWithMapname:(NSString *)mapname
                    withDescription:(NSString *)description
                      withIsPrivate:(BOOL)is_private
                withCompletionBlock:(void (^)(BOOL isSuccess, NSString* result))completionBlock;

// Map Update
+ (void)updateMapRequestWithMapPK:(NSInteger)map_pk
                      withMapname:(NSString *)mapname
                  withDescription:(NSString *)description
                    withIsPrivate:(BOOL)is_private
              withCompletionBlock:(void (^)(BOOL isSuccess, NSString* result))completionBlock;

// Map Delete
+ (void)deleteMapRequestWithMapData:(MomoMapDataSet *)mapData
                withCompletionBlock:(void (^)(BOOL isSuccess, NSString* result))completionBlock;



//********************************************************//
//                        Pin API                         //
//********************************************************//


// Pin Create
+ (void)createPinRequestWithPinname:(NSString *)pinname
                          withMapPK:(NSInteger)map_pk
                          withLabel:(NSInteger)pinLabel
                            withLat:(CGFloat)lat
                            withLng:(CGFloat)lng
                    withDescription:(NSString *)description
                withCompletionBlock:(void (^)(BOOL isSuccess, NSString* result))completionBlock;

// Pin Update
+ (void)updatePinRequestWithPinPK:(NSInteger)pin_pk
                      withPinname:(NSString *)pinname
                        withLabel:(NSInteger)pinLabel
                        withMapPK:(NSInteger)map_pk
              withCompletionBlock:(void (^)(BOOL isSuccess, NSString* result))completionBlock;

// Pin Delete
+ (void)deletePinRequestWithPinData:(MomoPinDataSet *)pinData
                withCompletionBlock:(void (^)(BOOL isSuccess, NSString* result))completionBlock;



//********************************************************//
//                        Post API                        //
//********************************************************//


// Post Create
+ (void)createPostRequestWithPinPK:(NSInteger)pin_pk
                     withPhotoData:(NSData *)photoData
                   withDescription:(NSString *)description
               withCompletionBlock:(void (^)(BOOL isSuccess, NSString* result))completionBlock;

// Post Update
+ (void)updatePostRequestWithPostPK:(NSInteger)post_pk
                          WithPinPK:(NSInteger)pin_pk
                      withPhotoData:(NSData *)photoData
                    withDescription:(NSString *)description
                withCompletionBlock:(void (^)(BOOL isSuccess, NSString* result))completionBlock;

// Post Delete
+ (void)deletePostRequestWithPostData:(MomoPostDataSet *)postData
                  withCompletionBlock:(void (^)(BOOL isSuccess, NSString* result))completionBlock;



@end
