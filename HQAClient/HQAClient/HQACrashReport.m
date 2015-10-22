//
//  HQACrashReport.m
//  HQAClient
//
//  Created by devholic on 2015. 10. 20..
//  Copyright © 2015년 honeyqa. All rights reserved.
//

#import "HQAConfig.h"

#import "HQACrashReport.h"

#import "HQADataObjectMerge.h"

#import "HQADeviceManager.h"

#import "CrashReporter/PLCrashReport.h"
#import "CrashReporter/PLCrashReportProcessorInfo.h"

@interface HQACrashReport()
{
    NSMutableArray              *_eventPaths;
    NSMutableArray              *_stackTrace;
    
    HQADataObjectMerge           *_mergeObject;
}

@end

@implementation HQACrashReport

- (void)refreshRequestData
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:@
                                 {
                                     @"errorname":_exceptionName,
                                     @"errorreason":_exceptionReason,
                                     @"function":_exceptionFunction,
                                     @"datetime":[NSDateFormatter localizedStringFromDate:_datetime dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterLongStyle]
                                 }];
    
    if (_eventPaths)
        [dict setObject:_eventPaths forKey:@"eventpaths"];
    if (_stackTrace)
        [dict setObject:_stackTrace forKey:@"callstack"];
    
    [_mergeObject setObject2:[[HQADataObject alloc] initWithData:dict]];
}

- (id)init
{
    self = [super init];
    if(self)
    {
        _mergeObject = [[HQADataObjectMerge alloc] init];
        
        _deviceInfo = nil;
        _eventPaths = [[NSMutableArray alloc] init];
        _stackTrace = [[NSMutableArray alloc] init];
        _exceptionName = @"";
        _exceptionReason = @"";
        _exceptionFunction = @"";
        _datetime = [NSDate date];
        
        [self refreshRequestData];
    }
    
    return self;
}

- (id)initWithCrashReport:(PLCrashReport *)crashReport deviceInfo:(HQADeviceInfo *)deviceInfo exceptionInfo:(HQAExceptionInfo *)exceptionInfo
{
    self = [super init];
    if (self)
    {
        _mergeObject = [[HQADataObjectMerge alloc] init];
        
        NSMutableArray *stackTrace = [NSMutableArray new];
        @try {
            for(PLCrashReportBinaryImageInfo *image in crashReport.images){
                image.
            }
            for (PLCrashReportThreadInfo *thread in crashReport.threads)
            {
                NSMutableDictionary *dict = [NSMutableDictionary new];
                NSMutableArray *stackArray = [NSMutableArray new];
                NSMutableArray *registerArray = [NSMutableArray new];
                for (NSInteger stackIndex = (exceptionInfo ? 4 : 0); stackIndex < thread.stackFrames.count; ++ stackIndex)
                {
                    PLCrashReportStackFrameInfo *stackFrame = thread.stackFrames[stackIndex];
                    
                    NSMutableDictionary *stackInfo = [NSMutableDictionary new];
                    
                    NSMutableDictionary *symbolBox = [NSMutableDictionary new];
                    if (stackFrame.symbolInfo)
                    {
                        [symbolBox setObject:stackFrame.symbolInfo.symbolName forKey:@"symbolName"];
                        [symbolBox setObject:[NSString stringWithFormat:@"0x%llx", stackFrame.symbolInfo.startAddress] forKey:@"startAddress"];
                        [symbolBox setObject:[NSString stringWithFormat:@"0x%llx", stackFrame.symbolInfo.endAddress] forKey:@"endAddress"];
                    }
                    else
                    {
                        [symbolBox setObject:@"" forKey:@"symbolName"];
                        [symbolBox setObject:@"0x0" forKey:@"startAddress"];
                        [symbolBox setObject:@"0x0" forKey:@"endAddress"];
                    }
                    
                    [stackInfo setObject:[NSString stringWithFormat:@"0x%llx", stackFrame.instructionPointer] forKey:@"instructionPointer"];
                    [stackInfo setObject:symbolBox forKey:@"symbol"];
                    
                    [stackArray addObject:stackInfo];
                }
                
                for (PLCrashReportRegisterInfo *registerInfo in thread.registers)
                {
                    NSMutableDictionary *registerBox = [NSMutableDictionary new];
                    [registerBox setObject:registerInfo.registerName forKey:@"registerName"];
                    [registerBox setObject:[NSString stringWithFormat:@"0x%llx", registerInfo.registerValue] forKey:@"registerValue"];
                    
                    [registerArray addObject:registerBox];
                }
                
                [dict setObject:IToS(thread.threadNumber) forKey:@"threadNumber"];
                [dict setObject:IToS(thread.crashed) forKey:@"crashed"];
                [dict setObject:stackArray forKey:@"stackFrame"];
                [dict setObject:registerArray forKey:@"registers"];
                
                [stackTrace addObject:dict];
            }
        }
        @catch (NSException *exception) {
#if HQA_ENABLE_ERROR_LOG
            HQALog(@"Error, Sending crash reports: %@", exception);
#endif
            return nil;
        }
        
        [self setDeviceInfo:[HQADeviceManager createDeviceReportFromCrashReport:crashReport deviceInfo:deviceInfo]];
        _eventPaths = [[NSMutableArray alloc] init];
        _stackTrace = stackTrace;
        if (exceptionInfo)
        {
            _exceptionName = exceptionInfo.exceptionName;
            _exceptionReason = exceptionInfo.exceptionReason;
            
            if ([exceptionInfo.stackTrace count] > 0)
                _exceptionFunction = exceptionInfo.stackTrace[0];
        }
        else
        {
            if (crashReport.hasExceptionInfo)
            {
                _exceptionName = crashReport.exceptionInfo.exceptionName;
                _exceptionReason = crashReport.exceptionInfo.exceptionReason;
                
                if ([crashReport.exceptionInfo.stackFrames count] > 2 &&
                    [crashReport.exceptionInfo.stackFrames[2] symbolInfo] &&
                    [crashReport.exceptionInfo.stackFrames[2] symbolInfo].symbolName)
                    _exceptionFunction = [crashReport.exceptionInfo.stackFrames[2] symbolInfo].symbolName;
            }
            else
            {
                _exceptionName = crashReport.signalInfo.name;
                _exceptionReason = crashReport.signalInfo.code;
                _exceptionFunction = [NSString stringWithFormat:@"0x%llx", crashReport.signalInfo.address];
            }
        }
        _datetime = crashReport.systemInfo.timestamp;
        
        [self refreshRequestData];
    }
    
    return self;
}

- (id)initWithData:(id)data
{
    return nil;
}

- (void)setDeviceInfo:(HQADeviceInfo *)deviceInfo
{
    _deviceInfo = deviceInfo;
    
    [_mergeObject setObject1:_deviceInfo];
}

- (void)setDatetime:(NSDate *)datetime
{
    _datetime = datetime;
    [self refreshRequestData];
}

- (void)setExceptionFunction:(NSString *)exceptionFunction
{
    _exceptionFunction = exceptionFunction;
    
    if (!_exceptionFunction)
        _exceptionFunction = @"";
    
    [self refreshRequestData];
}

- (void)setExceptionName:(NSString *)exceptionName
{
    _exceptionName = exceptionName;
    
    if (!_exceptionName)
        _exceptionName = @"";
    
    [self refreshRequestData];
}

- (void)setExceptionReason:(NSString *)exceptionReason
{
    _exceptionReason = exceptionReason;
    
    if (!_exceptionReason)
        _exceptionReason = @"";
    
    [self refreshRequestData];
}

- (NSArray *)eventPaths
{
    return [NSArray arrayWithArray:_eventPaths];
}

- (void)setEventPaths:(NSArray *)eventPaths
{
    _eventPaths = [NSMutableArray arrayWithArray:eventPaths];
    [self refreshRequestData];
}

- (NSArray *)stackTrace
{
    return [NSArray arrayWithArray:_stackTrace];
}

- (void)setStackTrace:(NSArray *)stackTrace
{
    _stackTrace = [NSMutableArray arrayWithArray:stackTrace];
    [self refreshRequestData];
}

- (id)objectData
{
    return [_mergeObject objectData];
}

@end
