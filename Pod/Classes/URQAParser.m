//
//  URQAParser.m
//  URQAClient
//
//  Created by devholic on 2015. 10. 20..
//  Copyright © 2015년 honeyqa. All rights reserved.
//

#import "URQAConfig.h"

#import "URQAParser.h"
#import "URQAJSONParser.h"
#import <objc/runtime.h>

@implementation URQAParser

+ (id)defaultParser
{
    static URQAParser *parserObject = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ([URQA_REQUST_TYPE isEqualToString:@"JSON"])
            parserObject = [[URQAJSONParser alloc] init];
        else
            parserObject = [[URQAParser alloc] init];
    });

    return parserObject;
}

+ (id)parserWithType:(NSString *)parserType
{
    Class classObject = objc_getClass([NSString stringWithFormat:@"URQA%@Parser", parserType].UTF8String);
    if(classObject)
        return [[classObject alloc] init];
    else
    {
        if ([URQA_REQUST_TYPE isEqualToString:@"JSON"])
            return [[URQAJSONParser alloc] init];
        else
            return [[URQAParser alloc] init];
    }
}

- (id)init
{
    return [super init];
}

- (NSData *)parseObject:(id)object
{
    if(object)
    {
        id objectData = nil;
        if ([object isKindOfClass:[URQADataObject class]])
            objectData = [object objectData];
        else
            objectData = object;

        if([objectData isKindOfClass:[NSString class]])
            return [objectData dataUsingEncoding:NSUTF8StringEncoding];
        else if([objectData isKindOfClass:[NSNumber class]])
            return [[objectData stringValue] dataUsingEncoding:NSUTF8StringEncoding];
    }
    return nil;
}

- (id)parseData:(NSData *)data
{
    return nil;
}

@end
