//
//  URQADataObject.m
//  URQAClient
//
//  Created by devholic on 2015. 10. 20..
//  Copyright © 2015년 honeyqa. All rights reserved.
//

#import "URQADataObject.h"

@interface URQADataObject()
{
    id              objectData;
}

@end

@implementation URQADataObject

- (id)init
{
    self = [super init];
    if(self)
    {
        objectData = nil;
    }

    return self;
}

- (id)initWithData:(id)data
{
    if(data && ([data isKindOfClass:[NSDictionary class]] || [data isKindOfClass:[NSArray class]]))
        self = [super init];

    if(self)
    {
        objectData = data;
    }

    return self;
}

- (id)objectData
{
    return objectData;
}

@end
