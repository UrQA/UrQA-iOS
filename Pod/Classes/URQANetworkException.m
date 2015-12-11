//
//  URQANetworkException.m
//  URQAClient
//
//  Created by devholic on 2015. 10. 20..
//  Copyright © 2015년 honeyqa. All rights reserved.
//

#import "URQANetworkException.h"
#import "URQADataObjectMerge.h"

#import <KeychainItemWrapper/KeychainItemWrapper.h>

#import "URQAConfig.h"

#define URQA_KEYCHAIN_ID        @"URQA_SECRET_UUID"

@interface URQANetworkException()
{
    URQADataObject        *_otherObject;
}

- (void)refreshRequestData;
- (NSString *)getUUID;

@end

@implementation URQANetworkException

- (void)refreshRequestData
{
    [(URQADataObjectMerge *)requestData setObject2:[[URQADataObject alloc] initWithData:@
                                                  {
                                                      @"sdkversion":URQA_VERSION,
                                                      @"apikey":_arguments[0],
                                                      @"rank":_arguments[2],
                                                      @"tag":_arguments[3],
                                                      @"deviceid":[self getUUID]
                                                  }]];
}

- (NSString *)getUUID
{
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:URQA_KEYCHAIN_ID accessGroup:nil];

    NSString *uuid = [wrapper objectForKey:(__bridge id)(kSecAttrAccount)];

    if (uuid == nil || uuid.length == 0)
    {
        if (![[UIDevice currentDevice] respondsToSelector:@selector(identifierForVendor)])
        {
            CFUUIDRef uuidRef = CFUUIDCreate(NULL);
            CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
            CFRelease(uuidRef);
            uuid = [NSString stringWithString:(__bridge NSString *)uuidStringRef];
            CFRelease(uuidStringRef);
        }
        else
        {
            uuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        }
        [wrapper setObject:uuid forKey:(__bridge id)(kSecAttrAccount)];
    }

    if (uuid == nil || uuid.length == 0)
        return @"None";
    else
        return uuid;
}

- (id)initWithAPIKey:(NSString *)APIKey andErrorReport:(URQACrashReport *)report andErrorRank:(URQAErrorRank)errorRank andTag:(NSString *)tag
{
    self = [super init];
    if(self)
    {
        tag = (!tag) ? @"" : tag;

        [_arguments addObject:(_APIKey = APIKey)];
        [_arguments addObject:(_crashReport = report)];
        [_arguments addObject:[NSNumber numberWithInteger:(_errorRank = errorRank)]];
        [_arguments addObject:(_tag = tag)];

        requestURL = [NSString stringWithFormat:@"%@%@", URQA_DOMAIN, @"/client/exception"];
        requestMethod = @"POST";
        requestHeader = nil;

        requestData = [[URQADataObjectMerge alloc] initWithObject1:_crashReport object2:nil];
        [self refreshRequestData];
    }

    return self;
}

- (void)setArguments:(NSMutableArray *)arguments
{
    [super setArguments:arguments];
    _APIKey = arguments[0];
    _crashReport = arguments[1];
    _errorRank = [arguments[2] integerValue];
    _tag = arguments[3];

    [(URQADataObjectMerge *)requestData setObject1:_crashReport];
    [self refreshRequestData];
}

- (void)setAPIKey:(NSString *)APIKey
{
    _arguments[0] = (_APIKey = APIKey);
    [self refreshRequestData];
}

- (void)setCrashReport:(URQACrashReport *)crashReport
{
    _arguments[1] = (_crashReport = crashReport);
    [(URQADataObjectMerge *)requestData setObject1:_crashReport];
    [self refreshRequestData];
}

- (void)setErrorRank:(URQAErrorRank)errorRank
{
    _arguments[2] = [NSNumber numberWithInteger:(_errorRank = errorRank)];
    [self refreshRequestData];
}

- (void)setTag:(NSString *)tag
{
    _arguments[3] = (_tag = tag);
    [self refreshRequestData];
}

- (BOOL)checkSuccess:(URQAResponse *)response
{
    if(response.responseCode == 200)
        return YES;

    return NO;
}

@end
