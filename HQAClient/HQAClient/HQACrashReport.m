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
#import "CrashReporter/PLCrashReportTextFormatter.h"

@interface HQACrashReport(PrivateAPI)
+ (NSString *) formatStackFrame: (PLCrashReportStackFrameInfo *) frameInfo
                     frameIndex: (NSUInteger) frameIndex
                         report: (PLCrashReport *) report
                           lp64: (BOOL) lp64;
+ (NSMutableDictionary *) parseStackFrame: (PLCrashReportStackFrameInfo *) frameInfo
                               frameIndex: (NSUInteger) frameIndex
                                   report: (PLCrashReport *) report
                                     lp64: (BOOL) lp64;
@end

@interface HQACrashReport()
{
    NSMutableArray              *_eventPaths;
    NSMutableDictionary              *_hqaData;
    HQADataObjectMerge          *_mergeObject;
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
    if (_hqaData)
        [dict setObject:_hqaData forKey:@"hqaData"];
    
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
        _hqaData = [[NSMutableDictionary alloc] init];
        _exceptionName = @"";
        _exceptionReason = @"";
        _exceptionFunction = @"";
        _datetime = [NSDate date];
        
        [self refreshRequestData];
    }
    
    return self;
}

// NSString* report = [PLCrashReportTextFormatter stringValueForCrashReport:crashReport withTextFormat: textFormat];
// NSLog(@"Crash log \n\n\n%@ \n\n\n", report);

- (id)initWithCrashReport:(PLCrashReport *)crashReport deviceInfo:(HQADeviceInfo *)deviceInfo exceptionInfo:(HQAExceptionInfo *)exceptionInfo
{
    self = [super init];
    if (self)
    {
        _mergeObject = [[HQADataObjectMerge alloc] init];
        _hqaData = [NSMutableDictionary new];
        // Create Report
        
        // report_arch
        // osName / codeType
        NSMutableDictionary *report_arch = [NSMutableDictionary new];
        boolean_t lp64 = true;
        switch (crashReport.systemInfo.operatingSystem) {
            case PLCrashReportOperatingSystemMacOSX:
                [report_arch setObject:@"Mac OS X" forKey:@"osName"];
                break;
            case PLCrashReportOperatingSystemiPhoneOS:
                [report_arch setObject:@"iPhone OS" forKey:@"osName"];
                break;
            case PLCrashReportOperatingSystemiPhoneSimulator:
                [report_arch setObject:@"Mac OS X" forKey:@"osName"];
                break;
            default:
                [report_arch setObject:[NSString stringWithFormat: @"Unknown (%d)", crashReport.systemInfo.operatingSystem] forKey:@"osName"];
                break;
        }
        /* Attempt to derive the code type from the binary images */
        for (PLCrashReportBinaryImageInfo *image in crashReport.images) {
            /* Skip images with no specified type */
            if (image.codeType == nil)
                continue;
            
            /* Skip unknown encodings */
            if (image.codeType.typeEncoding != PLCrashReportProcessorTypeEncodingMach)
                continue;
            
            switch (image.codeType.type) {
                case CPU_TYPE_ARM:
                    [report_arch setObject:@"ARM" forKey:@"codeType"];
                    lp64 = false;
                    break;
                    
                case CPU_TYPE_X86:
                    [report_arch setObject:@"X86" forKey:@"codeType"];
                    lp64 = false;
                    break;
                    
                case CPU_TYPE_X86_64:
                    [report_arch setObject:@"X86-64" forKey:@"codeType"];
                    lp64 = true;
                    break;
                    
                case CPU_TYPE_POWERPC:
                    [report_arch setObject:@"PPC" forKey:@"codeType"];
                    lp64 = false;
                    break;
                    
                default:
                    // Do nothing, handled below.
                    break;
            }
            
            /* Stop immediately if code type was discovered */
            if ([report_arch objectForKey:@"codeType"] != nil)
                break;
        }/* If we were unable to determine the code type, fall back on the legacy architecture value. */
        if ([report_arch objectForKey:@"codeType"] == nil) {
            switch (crashReport.systemInfo.architecture) {
                case PLCrashReportArchitectureARMv6:
                case PLCrashReportArchitectureARMv7:
                    [report_arch setObject:@"ARM" forKey:@"codeType"];
                    lp64 = false;
                    break;
                case PLCrashReportArchitectureX86_32:
                    [report_arch setObject:@"X86" forKey:@"codeType"];
                    lp64 = false;
                    break;
                case PLCrashReportArchitectureX86_64:
                    [report_arch setObject:@"X86-64" forKey:@"codeType"];
                    lp64 = true;
                    break;
                case PLCrashReportArchitecturePPC:
                    [report_arch setObject:@"PPC" forKey:@"codeType"];
                    lp64 = false;
                    break;
                default:
                    [report_arch setObject:[NSString stringWithFormat: @"Unknown (%d)", crashReport.systemInfo.architecture] forKey:@"codeType"];
                    lp64 = true;
                    break;
            }
        }
        [_hqaData setObject:report_arch forKey:@"arch"];
        NSString *unknownString = @"???";
        // report_process
        // process information / exception information
        NSMutableDictionary *report_process = [NSMutableDictionary new];
        [report_process setObject:unknownString forKey:@"processPath"];
        if (crashReport.hasProcessInfo) {
            if (crashReport.processInfo.processPath != nil)
                [report_process setObject:crashReport.processInfo.processPath forKey:@"processPath"];
        }
        if (crashReport.hasExceptionInfo) {
            [report_process setObject:crashReport.exceptionInfo.exceptionName forKey:@"exceptionName"];
            [report_process setObject:crashReport.exceptionInfo.exceptionReason forKey:@"exceptionReason"];
        }
        /* If an exception stack trace is available, output an Apple-compatible backtrace. */
        if (crashReport.exceptionInfo != nil && crashReport.exceptionInfo.stackFrames != nil && [crashReport.exceptionInfo.stackFrames count] > 0) {
            PLCrashReportExceptionInfo *exception = crashReport.exceptionInfo;
            NSMutableArray *eStackArray = [NSMutableArray new];
            /* Write out the frames. In raw reports, Apple writes this out as a simple list of PCs. In the minimally
             * post-processed report, Apple writes this out as full frame entries. We use the latter format. */
            for (NSUInteger frame_idx = 0; frame_idx < [exception.stackFrames count]; frame_idx++) {
                PLCrashReportStackFrameInfo *frameInfo = [exception.stackFrames objectAtIndex: frame_idx];
                [eStackArray addObject:[HQACrashReport formatStackFrame: frameInfo frameIndex: frame_idx report: crashReport lp64: lp64]];
            }
            [report_process setObject:eStackArray forKey:@"exceptionStack"];
        }
        [_hqaData setObject:report_process forKey:@"process"];
        // report_thread
        // thread information
        NSMutableArray *report_thread = [NSMutableArray new];
        PLCrashReportThreadInfo *crashed_thread = nil;
        for (PLCrashReportThreadInfo *thread in crashReport.threads) {
            NSMutableDictionary *ti = [NSMutableDictionary new];
            if (thread.crashed) {
                [ti setObject:@"1" forKey:@"isCrashed"];
                crashed_thread = thread;
            }else{
                [ti setObject:@"0" forKey:@"isCrashed"];
            }
            NSMutableArray *frame = [NSMutableArray new];
            for (NSUInteger frame_idx = 0; frame_idx < [thread.stackFrames count]; frame_idx++) {
                PLCrashReportStackFrameInfo *frameInfo = [thread.stackFrames objectAtIndex: frame_idx];
                NSMutableDictionary *t = [HQACrashReport parseStackFrame:frameInfo frameIndex:frame_idx report:crashReport lp64:lp64];
                [frame addObject:t];
            }
            [ti setObject:frame forKey:@"frame"];
            [report_thread addObject:ti];
        }
        [_hqaData setObject:report_thread forKey:@"thread"];
        /* Registers */
        NSMutableDictionary *report_register = [NSMutableDictionary new];
        if (crashed_thread != nil) {
            for (PLCrashReportRegisterInfo *reg in crashed_thread.registers) {
               /* Remap register names to match Apple's crash reports */
                NSString *regName = reg.registerName;
                if (crashReport.machineInfo != nil && crashReport.machineInfo.processorInfo.typeEncoding == PLCrashReportProcessorTypeEncodingMach) {
                    PLCrashReportProcessorInfo *pinfo = crashReport.machineInfo.processorInfo;
                    cpu_type_t arch_type = pinfo.type & ~CPU_ARCH_MASK;
                    
                    /* Apple uses 'ip' rather than 'r12' on ARM */
                    if (arch_type == CPU_TYPE_ARM && [regName isEqual: @"r12"]) {
                        regName = @"ip";
                    }
                }
                if (lp64)
                    [report_register setObject:[NSString stringWithFormat:@"0x%016" PRIx64, reg.registerValue] forKey:[NSString stringWithFormat:@"%s", [regName UTF8String]]];
                else
                    [report_register setObject:[NSString stringWithFormat:@"0x%08" PRIx64, reg.registerValue] forKey:[NSString stringWithFormat:@"%s", [regName UTF8String]]];
            }
        }
        [_hqaData setObject:report_register forKey:@"register"];
        [self setDeviceInfo:[HQADeviceManager createDeviceReportFromCrashReport:crashReport deviceInfo:deviceInfo]];
        _eventPaths = [[NSMutableArray alloc] init];
        // _stackTrace = stackTrace;
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

- (NSDictionary *)hqaData
{
    return [NSDictionary dictionaryWithDictionary:_hqaData];
}

- (void)setHqaData:(NSDictionary *)hqaData
{
    _hqaData = [NSMutableDictionary dictionaryWithDictionary:hqaData];
    [self refreshRequestData];
}

- (id)objectData
{
    return [_mergeObject objectData];
}

@end

@implementation HQACrashReport (PrivateMethods)

+ (NSString *) formatStackFrame: (PLCrashReportStackFrameInfo *) frameInfo
                     frameIndex: (NSUInteger) frameIndex
                         report: (PLCrashReport *) report
                           lp64: (BOOL) lp64
{
    /* Base image address containing instrumention pointer, offset of the IP from that base
     * address, and the associated image name */
    uint64_t baseAddress = 0x0;
    uint64_t pcOffset = 0x0;
    NSString *imageName = @"\?\?\?";
    NSString *symbolString = nil;
    
    PLCrashReportBinaryImageInfo *imageInfo = [report imageForAddress: frameInfo.instructionPointer];
    if (imageInfo != nil) {
        imageName = [imageInfo.imageName lastPathComponent];
        baseAddress = imageInfo.imageBaseAddress;
        pcOffset = frameInfo.instructionPointer - imageInfo.imageBaseAddress;
    }
    
    /* If symbol info is available, the format used in Apple's reports is Sym + OffsetFromSym. Otherwise,
     * the format used is imageBaseAddress + offsetToIP */
    if (frameInfo.symbolInfo != nil) {
        NSString *symbolName = frameInfo.symbolInfo.symbolName;
        
        /* Apple strips the _ symbol prefix in their reports. Only OS X makes use of an
         * underscore symbol prefix by default. */
        if ([symbolName rangeOfString: @"_"].location == 0 && [symbolName length] > 1) {
            switch (report.systemInfo.operatingSystem) {
                case PLCrashReportOperatingSystemMacOSX:
                case PLCrashReportOperatingSystemiPhoneOS:
                case PLCrashReportOperatingSystemiPhoneSimulator:
                    symbolName = [symbolName substringFromIndex: 1];
                    break;
                    
                default:
                    NSLog(@"Symbol prefix rules are unknown for this OS!");
                    break;
            }
        }
        
        
        uint64_t symOffset = frameInfo.instructionPointer - frameInfo.symbolInfo.startAddress;
        symbolString = [NSString stringWithFormat: @"%@ + %" PRId64, symbolName, symOffset];
    } else {
        symbolString = [NSString stringWithFormat: @"0x%" PRIx64 " + %" PRId64, baseAddress, pcOffset];
    }
    
    /* Note that width specifiers are ignored for %@, but work for C strings.
     * UTF-8 is not correctly handled with %s (it depends on the system encoding), but
     * UTF-16 is supported via %S, so we use it here */
    return [NSString stringWithFormat: @"%-4ld%-35S 0x%0*" PRIx64 " %@",
            (long) frameIndex,
            (const uint16_t *)[imageName cStringUsingEncoding: NSUTF16StringEncoding],
            lp64 ? 16 : 8, frameInfo.instructionPointer,
            symbolString];
}

+ (NSMutableDictionary *) parseStackFrame: (PLCrashReportStackFrameInfo *) frameInfo
                               frameIndex: (NSUInteger) frameIndex
                                   report: (PLCrashReport *) report
                                     lp64: (BOOL) lp64
{
    /* Base image address containing instrumention pointer, offset of the IP from that base
     * address, and the associated image name */
    NSMutableDictionary *result = [NSMutableDictionary new];
    uint64_t baseAddress = 0x0;
    uint64_t pcOffset = 0x0;
    NSString *imageName = @"\?\?\?";
    
    PLCrashReportBinaryImageInfo *imageInfo = [report imageForAddress: frameInfo.instructionPointer];
    if (imageInfo != nil) {
        imageName = [imageInfo.imageName lastPathComponent];
        baseAddress = imageInfo.imageBaseAddress;
        pcOffset = frameInfo.instructionPointer - imageInfo.imageBaseAddress;
    }
    
    /* If symbol info is available, the format used in Apple's reports is Sym + OffsetFromSym. Otherwise,
     * the format used is imageBaseAddress + offsetToIP */
    if (frameInfo.symbolInfo != nil) {
        NSString *symbolName = frameInfo.symbolInfo.symbolName;
        
        /* Apple strips the _ symbol prefix in their reports. Only OS X makes use of an
         * underscore symbol prefix by default. */
        if ([symbolName rangeOfString: @"_"].location == 0 && [symbolName length] > 1) {
            switch (report.systemInfo.operatingSystem) {
                case PLCrashReportOperatingSystemMacOSX:
                case PLCrashReportOperatingSystemiPhoneOS:
                case PLCrashReportOperatingSystemiPhoneSimulator:
                    symbolName = [symbolName substringFromIndex: 1];
                    break;
                    
                default:
                    NSLog(@"Symbol prefix rules are unknown for this OS!");
                    break;
            }
        }
        
        uint64_t symOffset = frameInfo.instructionPointer - frameInfo.symbolInfo.startAddress;
        [result setObject:symbolName forKey:@"symbolName"];
        [result setObject:[NSString stringWithFormat: @"%" PRId64, symOffset] forKey:@"offset"];
    } else {
        [result setObject:[NSString stringWithFormat: @"0x%" PRIx64, baseAddress] forKey:@"baseAddress"];
        [result setObject:[NSString stringWithFormat: @"%" PRId64, pcOffset] forKey:@"offset"];
    }
    [result setObject:[NSString stringWithFormat: @"%ld",(long)frameIndex] forKey:@"frameIndex"];
    [result setObject:[NSString stringWithFormat: @"%S",(const uint16_t *)[imageName cStringUsingEncoding: NSUTF16StringEncoding]] forKey:@"imageName"];
    [result setObject:[NSString stringWithFormat: @"0x%0*" PRIx64,lp64 ? 16 : 8, frameInfo.instructionPointer] forKey:@"frameIndex"];
    return result;
}

@end
