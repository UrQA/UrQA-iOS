//
//  HQAParser.m
//  HQAClient
//
//  Created by devholic on 2015. 10. 20..
//  Copyright © 2015년 honeyqa. All rights reserved.
//

#import "HQAConfig.h"

#import "HQAParser.h"
#import "HQAJSONParser.h"
#import <objc/runtime.h>

@implementation HQAParser

+ (id)defaultParser
{
    static HQAParser *parserObject = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ([HQA_REQUST_TYPE isEqualToString:@"JSON"])
            parserObject = [[HQAJSONParser alloc] init];
        else
            parserObject = [[HQAParser alloc] init];
    });
    
    return parserObject;
}

+ (id)parserWithType:(NSString *)parserType
{
    Class classObject = objc_getClass([NSString stringWithFormat:@"HQA%@Parser", parserType].UTF8String);
    if(classObject)
        return [[classObject alloc] init];
    else
    {
        if ([HQA_REQUST_TYPE isEqualToString:@"JSON"])
            return [[HQAJSONParser alloc] init];
        else
            return [[HQAParser alloc] init];
    }
}

- (id)init
{
    return [super init];
}

- (NSData *)parseObject:(id)object
{
    NSLog(@"ParseObject");
    if(object)
    {
        id objectData = nil;
        if ([object isKindOfClass:[HQADataObject class]])
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
