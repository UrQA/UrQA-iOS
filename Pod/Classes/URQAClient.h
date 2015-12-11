//
//  URQAClient.h
//  URQAClient
//
//  Created by devholic on 2015. 10. 19..
//  Copyright © 2015 honeyqa. All rights reserved.
//

#import "URQADefines.h"

//! Project version number for URQAClient.
FOUNDATION_EXPORT double URQAClientVersionNumber;

//! Project version string for URQAClient.
FOUNDATION_EXPORT const unsigned char URQAClientVersionString[];

// #define URQALog(_EXCEPTION, _TAG)       [URQAClient logException:_EXCEPTION withTag:_TAG];
#define URQABreadcrumb(_BREADCRUMB)     [URQAClient leaveBreadcrumb:__LINE__ prettyFunction:__PRETTY_FUNCTION__ label:_BREADCRUMB];

@interface URQAClient : NSObject

+ (NSString *)APIKey;
+ (void)setAPIKey:(NSString *)APIKey;

+ (URQAClient *)sharedController;
+ (URQAClient *)sharedControllerWithAPIKey:(NSString *)APIKey;

+ (BOOL)leaveBreadcrumb:(NSInteger)lineNumber;
+ (BOOL)leaveBreadcrumb:(NSInteger)lineNumber label:(NSString *)breadcrumb;
+ (BOOL)leaveBreadcrumb:(NSInteger)lineNumber prettyFunction:(const char *)prettyFunction label:(NSString *)breadcrumb;

+ (BOOL)logException:(NSException *)exception;
+ (BOOL)logException:(NSException *)exception withTag:(NSString *)tag;
+ (BOOL)logException:(NSException *)exception withTag:(NSString *)tag andErrorRank:(URQAErrorRank)errorRank;

@end
