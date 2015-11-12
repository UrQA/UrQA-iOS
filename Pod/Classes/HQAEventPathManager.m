//
//  HQAEventPathManager.m
//  HQAClient
//
//  Created by devholic on 2015. 10. 20..
//  Copyright © 2015년 honeyqa. All rights reserved.
//

#import "HQAEventPathManager.h"
#import "HQAEventPath.h"

static const NSInteger kMaxEventPath            = 10;

@interface HQAEventPathManager()
{
    NSMutableArray          *_eventPaths;
}

@end

@implementation HQAEventPathManager

+ (HQAEventPathManager *)sharedInstance
{
    static HQAEventPathManager *manager = nil;
    
    // It makes singleton object thread-safe
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[HQAEventPathManager alloc] init];
    });
    
    return manager;
}

- (id)init
{
    self = [super init];
    if(self)
    {
        _eventPaths = [[NSMutableArray alloc] initWithCapacity:kMaxEventPath];
    }
    
    return self;
}

- (BOOL)createEventPath:(NSInteger)step lineNumber:(NSInteger)linenum
{
    [self createEventPath:(step+1) lineNumber:linenum label:@""];
    return NO;
}

- (BOOL)createEventPath:(NSInteger)step lineNumber:(NSInteger)linenum label:(NSString *)label
{
    NSArray *stackTrace = [NSThread callStackSymbols];
    NSArray *stepArray = [stackTrace[step] componentsSeparatedByString:@" "];
    NSMutableArray *stepInfo = [[NSMutableArray alloc] init];
    for(NSString *str in stepArray)
    {
        if(![str isEqualToString:@""])
            [stepInfo addObject:str];
    }
    
    NSMutableString *prettyFunction = [[NSMutableString alloc] init];
    for (NSInteger i = 3; i < stepInfo.count; i ++)
    {
        [prettyFunction appendString:stepInfo[i]];
        [prettyFunction appendString:@" "];
    }
    
    [self createEventPath:step lineNumber:linenum prettyFunction:prettyFunction label:label];
    
    return YES;
}

- (BOOL)createEventPath:(NSInteger)step lineNumber:(NSInteger)linenum prettyFunction:(NSString *)prettyFunction label:(NSString *)label
{
    HQAEventPath *eventPath = [[HQAEventPath alloc] init];
    eventPath.prettyFunction = prettyFunction;
    eventPath.lineNum = linenum;
    eventPath.dateTime = [NSDate date];
    eventPath.label = label;
    
    if([_eventPaths count] >= kMaxEventPath)
        [_eventPaths removeObjectAtIndex:0];
    [_eventPaths addObject:eventPath];
    
    return YES;
}

- (NSArray *)eventPath
{
    return [NSArray arrayWithArray:_eventPaths];
}

- (void)removeAllObjects
{
    [_eventPaths removeAllObjects];
}

- (NSArray *)arrayData
{
    NSMutableArray *arrayData = [[NSMutableArray alloc] initWithCapacity:_eventPaths.count];
    for(HQAEventPath *eventPath in _eventPaths)
        [arrayData addObject:[eventPath objectData]];
    
    return [NSArray arrayWithArray:arrayData];
}

@end
