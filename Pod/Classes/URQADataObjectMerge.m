//
//  URQADataObjectMerge.m
//  URQAClient
//
//  Created by devholic on 2015. 10. 20..
//  Copyright © 2015년 honeyqa. All rights reserved.
//

#import "URQADataObjectMerge.h"

@implementation URQADataObjectMerge

- (id)initWithObject1:(URQADataObject *)obj1 object2:(URQADataObject *)obj2
{
    self = [super init];
    if(self)
    {
        _object1 = obj1;
        _object2 = obj2;
    }

    return self;
}

- (id)initWithData:(id)data
{
    return nil;
}

- (id)objectData
{
    id data1 = [_object1 objectData];
    id data2 = [_object2 objectData];

    if(_object1 && _object2)
    {
        if([data1 isKindOfClass:[NSArray class]] && [data2 isKindOfClass:[NSArray class]])
        {
            NSMutableArray *array = [[NSMutableArray alloc] initWithArray:data1];
            [array addObjectsFromArray:data2];

            return array;
        }
        else if([data1 isKindOfClass:[NSDictionary class]] && [data2 isKindOfClass:[NSDictionary class]])
        {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:data1];
            [dict addEntriesFromDictionary:data2];

            return dict;
        }
        else
        {
            NSArray *array = [NSArray arrayWithObjects:data1, data2, nil];

            return array;
        }
    }
    else
        return data2;
}

@end
