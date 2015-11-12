//
//  HQAEventPath.m
//  HQAClient
//
//  Created by devholic on 2015. 10. 20..
//  Copyright © 2015년 honeyqa. All rights reserved.
//

#import "HQAEventPath.h"

@implementation HQAEventPath

- (id)init
{
    self = [super init];
    if(self)
    {
        _prettyFunction = nil;
        _lineNum = -1;
        _dateTime = nil;
        _label = nil;
    }
    
    return self;
}

- (id)initWithData:(id)data
{
    self = [super initWithData:data];
    if(self)
    {
        _prettyFunction = [data valueForKey:@"prettyfunction"];
        _label = [data valueForKey:@"label"];
        _lineNum = [[data valueForKey:@"linenum"] integerValue];
        _dateTime = [[[NSDateFormatter alloc] init] dateFromString:[data valueForKey:@"datetime"]];
    }
    
    return self;
}

- (id)objectData
{
    return @{@"datetime"        : [NSDateFormatter localizedStringFromDate:_dateTime dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterLongStyle],
             @"prettyfunction"  : _prettyFunction,
             @"linenum"         : [NSNumber numberWithLong:_lineNum],
             @"label"           : _label};
}

@end
