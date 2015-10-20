//
//  HQANetworkExceptionLog.m
//  HQAClient
//
//  Created by devholic on 2015. 10. 20..
//  Copyright © 2015년 honeyqa. All rights reserved.
//

#import "HQANetworkExceptionLog.h"

#import "HQAConfig.h"

#import "CrashReporter/CrashReporter.h"
#import "CrashReporter/PLCrashReportTextFormatter.h"

@interface HQANetworkExceptionLog()
{
    NSArray             *_objects;
}

@end

@implementation HQANetworkExceptionLog

- (id)initWithObject:(NSArray *)objects
{
    self = [super init];
    if(self)
    {
        _objects = objects;
    }
    
    return self;
}

- (NSString *)requestMethod
{
    return @"POST";
}

- (NSString *)requestURL
{
    return [NSString stringWithFormat:HQA_DOMAIN @"/client/exception/log/%@", _objects[0]];
}

- (id)requestData
{
    return [NSString stringWithFormat:@""];
}

- (BOOL)isSuccessCheck:(NSString *)responseString andReponseCode:(NSInteger)code
{
    if(code == 200 && [responseString isEqualToString:@"{ ok }"])
        return YES;
    return NO;
}

@end
