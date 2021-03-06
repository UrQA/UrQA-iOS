//
//  URQAJSONParser.m
//  URQAClient
//
//  Created by devholic on 2015. 10. 20..
//  Copyright © 2015년 honeyqa. All rights reserved.
//

#import "URQAJSONParser.h"
#import <JSONKit-NoWarning/JSONKit.h>

@implementation URQAJSONParser

- (id)init
{
    return self = [super init];
}

- (NSData *)parseObject:(id)object
{
    if(object)
    {
        id objectData = nil;
        if ([object isKindOfClass:[URQADataObject class]]){
            objectData = [object objectData];
        }
        else{
            objectData = object;
        }
        if([objectData isKindOfClass:[NSArray class]] ||
           [objectData isKindOfClass:[NSDictionary class]]){
            return [objectData JSONData];
        }
    }
    return [super parseObject:object];
}

- (id)parseData:(NSData *)data
{
    return [data objectFromJSONData];
}

@end
