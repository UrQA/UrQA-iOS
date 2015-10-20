//
//  HQAClient.h
//  HQAClient
//
//  Created by devholic on 2015. 10. 19..
//  Copyright © 2015 honeyqa. All rights reserved.
//

#import "HQADefines.h"

//! Project version number for HQAClient.
FOUNDATION_EXPORT double HQAClientVersionNumber;

//! Project version string for HQAClient.
FOUNDATION_EXPORT const unsigned char HQAClientVersionString[];

// #define HQALog(_EXCEPTION, _TAG)       [HQAClient logException:_EXCEPTION withTag:_TAG];
#define HQABreadcrumb(_BREADCRUMB)     [HQAClient leaveBreadcrumb:__LINE__ prettyFunction:__PRETTY_FUNCTION__ label:_BREADCRUMB];

@interface HQAClient : NSObject

+ (NSString *)APIKey;
+ (void)setAPIKey:(NSString *)APIKey;

+ (HQAClient *)sharedController;
+ (HQAClient *)sharedControllerWithAPIKey:(NSString *)APIKey;

+ (BOOL)leaveBreadcrumb:(NSInteger)lineNumber;
+ (BOOL)leaveBreadcrumb:(NSInteger)lineNumber label:(NSString *)breadcrumb;
+ (BOOL)leaveBreadcrumb:(NSInteger)lineNumber prettyFunction:(const char *)prettyFunction label:(NSString *)breadcrumb;

+ (BOOL)logException:(NSException *)exception;
+ (BOOL)logException:(NSException *)exception withTag:(NSString *)tag;
+ (BOOL)logException:(NSException *)exception withTag:(NSString *)tag andErrorRank:(HQAErrorRank)errorRank;

@end
