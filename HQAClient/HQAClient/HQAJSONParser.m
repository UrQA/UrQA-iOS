//
//  HQAJSONParser.m
//  HQAClient
//
//  Created by devholic on 2015. 10. 20..
//  Copyright © 2015년 honeyqa. All rights reserved.
//

#import "HQAJSONParser.h"
#import "JSONKit.h"

@implementation HQAJSONParser

- (id)init
{
    return self = [super init];
}

- (NSData *)parseObject:(id)object
{
    NSLog(@"ParseJSONObject");
    if(object)
    {
        id objectData = nil;
        NSLog(@"ParseJSONObjectA");
        if ([object isKindOfClass:[HQADataObject class]]){
            NSLog(@"ParseJSONObjectB");
            objectData = [object objectData];
        }
        else{
            objectData = object;
            NSLog(@"ParseJSONObjectC");
        }
        if([objectData isKindOfClass:[NSArray class]] ||
           [objectData isKindOfClass:[NSDictionary class]]){
            NSLog(@"ParseJSONObjectD");
            return [objectData JSONData];
        }
    }
    NSLog(@"ParseJSONObjectE");
    return [super parseObject:object];
}

- (id)parseData:(NSData *)data
{
    return [data objectFromJSONData];
}

@end
