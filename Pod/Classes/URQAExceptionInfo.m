//
//  URQAExceptionInfo.m
//  URQAClient
//
//  Created by devholic on 2015. 10. 20..
//  Copyright © 2015년 honeyqa. All rights reserved.
//

#import "URQAExceptionInfo.h"

@implementation URQAExceptionInfo

- (id)init
{
    self = [super init];
    if (self)
    {
        _exceptionName = @"";
        _exceptionReason = @"";
        _stackTrace = @[];
        _tag = @"";
        _errorRank = URQAErrorRankUnhandle;
    }
    
    return self;
}

- (id)initWithData:(id)data
{
    self = [super initWithData:data];
    if (self)
    {
        _exceptionName   = DInKToS(data, @"exceptionName");
        _exceptionReason = DInKToS(data, @"exceptionReason");
        _stackTrace      = DInKToS(data, @"stackTrace");
        _tag             = DInKToS(data, @"tag");
        _errorRank       = (URQAErrorRank)DInKToI(data, @"errorRank");
    }

    return self;
}

- (id)initWithException:(NSException *)exception
{
    self = [super init];
    if (self)
    {
        @try
        {
            NSArray *callStack = [NSThread callStackReturnAddresses];
            NSArray *callStackInfo = [NSThread callStackSymbols];
            NSMutableArray *stackTrace = [NSMutableArray new];
            NSCharacterSet *separatorSet = [NSCharacterSet characterSetWithCharactersInString:@" -[]+?.,"];
            for (int i = 3; i < callStack.count - 1; ++i)
            {
                NSArray *stepArray = [callStackInfo[i] componentsSeparatedByString:@" "];
                NSMutableArray *stepInfo = [[NSMutableArray alloc] init];
                for(NSString *str in stepArray)
                {
                    if(![str isEqualToString:@""])
                        [stepInfo addObject:str];
                }

                NSMutableString *prettyFunction = [[NSMutableString alloc] init];
                for (NSInteger j = 3; j < stepInfo.count; j ++)
                {
                    [prettyFunction appendString:stepInfo[j]];
                    [prettyFunction appendString:@" "];
                }

                stepArray = [prettyFunction componentsSeparatedByString:@" + "];
                NSMutableArray *URQARaw = [NSMutableArray arrayWithArray:[callStackInfo[i]  componentsSeparatedByCharactersInSet:separatorSet]];
                [URQARaw removeObject:@""];
                long instructionPointer = (long)[callStack[i] integerValue];
                long minusAddress = (long)[stepArray[1] integerValue];
                [stackTrace addObject:@{@"URQARaw":URQARaw,
                                        @"instructionPointer":[NSString stringWithFormat:@"0x%lx", instructionPointer],
                                        @"symbol":@{@"endAddress":@"0x0",
                                                    @"startAddress":[NSString stringWithFormat:@"0x%lx", (instructionPointer - minusAddress)],
                                                    @"symbolName":stepArray[0]}
                                        }];
            }

            _stackTrace = stackTrace;
        }
        @catch(NSException *exception)
        {
            _stackTrace = @[];
        }

        _exceptionName   = exception.name;
        _exceptionReason = exception.reason;
        _tag             = @"";
        _errorRank       = URQAErrorRankUnhandle;
    }

    return self;
}

- (void)setExceptionName:(NSString *)exceptionName
{
    if (exceptionName)
        _exceptionName = exceptionName;
}

- (void)setExceptionReason:(NSString *)exceptionReason
{
    if (exceptionReason)
        _exceptionReason = exceptionReason;
}

- (void)setStackTrace:(NSArray *)stackTrace
{
    if (stackTrace)
        _stackTrace = stackTrace;
}

- (void)setTag:(NSString *)tag
{
    if (tag)
        _tag = tag;
    else
        _tag = @"";
}

- (id)objectData
{
    return @{@"exceptionName"       : _exceptionName,
             @"exceptionReason"     : _exceptionReason,
             @"stackTrace"          : _stackTrace,
             @"tag"                 : _tag,
             @"errorRank"           : IToS(_errorRank)};
}

@end
