//
//  HQAClient.m
//  HQAClient
//
//  Created by devholic on 2015. 10. 19..
//  Copyright © 2015년 honeyqa. All rights reserved.
//

#import "HQAConfig.h"
#import "HQAClient.h"

#import "HQADeviceManager.h"
#import "HQAEventPathManager.h"
#import "HQANetworkConnect.h"
#import "HQANetworkException.h"
#import "HQAExceptionInfo.h"
#import "HQAParser.h"

#import "CrashReporter/CrashReporter.h"
#import "CrashReporter/PLCrashReportTextFormatter.h"
#import "CrashReporter/PLCrashReportRegisterInfo.h"
#import "CrashReporter/PLCrashReportStackFrameInfo.h"
#import "CrashReporter/PLCrashReportTextFormatter.h"

#import <sys/sysctl.h>
#import <pthread.h>

@interface HQAClient()
{
    BOOL                                    _isSendingCrash;
    
    NSString                                *_sessionKey;
    
    NSString                                *_crashQueuePath;
    NSMutableArray                          *_crashQueueFiles;
    
    HQANetworkConnect                        *_sessionRequester;
}

@property (nonatomic, retain) NSString      *secretAPIKey;
@property (nonatomic, retain) HQAParser  *dataParser;

@end

static HQAClient           *_hqaController;
static HQAEventPathManager       *_eventPathManager;
static PLCrashReporter          *_crashReporter;

@implementation HQAClient

#pragma mark -
#pragma mark Exception Callback

/* Exception callback.
 */
void postCrashCallback(siginfo_t *info, ucontext_t *uap, void *context)
{
    // This is not async-safe!!! Beware!!!
    if([_crashReporter hasPendingCrashReport])
    {
        [_hqaController processCrashReporter];
        
        CFRunLoopRef runLoop = CFRunLoopGetCurrent();
        CFArrayRef allModes = CFRunLoopCopyAllModes(runLoop);
        
        for (NSString *mode in (__bridge NSArray *)allModes) {
            CFRunLoopRunInMode((__bridge CFStringRef)mode, 0.001, false);
        }
        
        CFRelease(allModes);
        
        NSSetUncaughtExceptionHandler(NULL);
        signal(SIGABRT, SIG_DFL);
        signal(SIGILL, SIG_DFL);
        signal(SIGSEGV, SIG_DFL);
        signal(SIGFPE, SIG_DFL);
        signal(SIGBUS, SIG_DFL);
        signal(SIGPIPE, SIG_DFL);
        
        HQALog(@"Immediate dispatch completed!");
        
        abort();
    }
}

/* Check device debugged.
 */

bool beingDebugged(void)
{
    int                 junk;
    int                 mib[4];
    struct kinfo_proc   info;
    size_t              size;
    
    info.kp_proc.p_flag = 0;
    
    mib[0] = CTL_KERN;
    mib[1] = KERN_PROC;
    mib[2] = KERN_PROC_PID;
    mib[3] = getpid();
    
    size = sizeof(info);
    junk = sysctl(mib, sizeof(mib) / sizeof(*mib), &info, &size, NULL, 0);
    if (junk != 0)
        return YES;
    
    return ((info.kp_proc.p_flag & P_TRACED) != 0);
}


#pragma mark -
#pragma mark Public Methods

/* APIKey modify.
 */
+ (NSString *)APIKey
{
    return [[HQAClient sharedController] secretAPIKey];
}

+ (void)setAPIKey:(NSString *)APIKey
{
    [[HQAClient sharedController] setSecretAPIKey:APIKey];
}

/* Singleton.
 */
+ (HQAClient *)sharedController
{
    // It makes singleton object thread-safe
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _hqaController = [[HQAClient alloc] init];
    });
    
    return _hqaController;
}

+ (HQAClient *)sharedControllerWithAPIKey:(NSString *)APIKey
{
    HQAClient *controller = [HQAClient sharedController];
    [controller setSecretAPIKey:APIKey];
    return controller;
}

/* Logging eventpath.
 */
+ (BOOL)leaveBreadcrumb:(NSInteger)lineNumber
{
    [_eventPathManager createEventPath:2 lineNumber:lineNumber];
    return YES;
}

+ (BOOL)leaveBreadcrumb:(NSInteger)lineNumber label:(NSString *)breadcrumb
{
    [_eventPathManager createEventPath:2 lineNumber:lineNumber label:breadcrumb];
    return YES;
}

+ (BOOL)leaveBreadcrumb:(NSInteger)lineNumber prettyFunction:(const char *)prettyFunction label:(NSString *)breadcrumb
{
    [_eventPathManager createEventPath:2 lineNumber:lineNumber prettyFunction:[NSString stringWithUTF8String:prettyFunction] label:breadcrumb];
    return YES;
}

/* Logging Exception.
 */
+ (BOOL)logException:(NSException *)exception
{
    return [_hqaController saveException:exception tag:@"" errorRank:HQAErrorRankUnhandle];;
}

+ (BOOL)logException:(NSException *)exception withTag:(NSString *)tag
{
    return [_hqaController saveException:exception tag:tag errorRank:HQAErrorRankUnhandle];;
}

+ (BOOL)logException:(NSException *)exception withTag:(NSString *)tag andErrorRank:(HQAErrorRank)errorRank
{
    return [_hqaController saveException:exception tag:tag errorRank:errorRank];;
}


#pragma mark -
#pragma mark Initialize

/* Memory allocation.
 */
- (id)init
{
    self = [super init];
    if (self)
    {
        /* Initialize */
        _isSendingCrash = NO;
        _secretAPIKey = nil;
        _sessionKey = nil;
        _crashQueueFiles = [NSMutableArray new];
        _sessionRequester = nil;
        _dataParser = [HQAParser defaultParser];
        
        if(!_eventPathManager)
            _eventPathManager = [HQAEventPathManager sharedInstance];
    }
    
    return self;
}

#pragma mark -
#pragma mark Private Getter/Setter

/* HoneyQA Processing Start when APIKey is modified.
 */
- (void)setSecretAPIKey:(NSString *)secretAPIKey
{
    _secretAPIKey = secretAPIKey;
    if (!_sessionRequester)
    {
        _sessionRequester = [[HQANetworkConnect alloc] initWithAPIKey:_secretAPIKey deviceInfo:[HQADeviceManager createDeviceReport]];
        [self captureCrash];
    }
    [self sessionUpdate];
    [self sendCrashReporter];
}


#pragma mark -
#pragma mark Private Methods

/* Crash reporter initalize.
 */
- (void)captureCrash
{
    HQALog(@"Debug mode: %@", beingDebugged() ? @"YES" : @"NO");
#if TARGET_IPHONE_SIMULATOR
    HQALog(@"Device Mode: Simulator");
#else
    HQALog(@"Device mode: Device");
#endif
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    /* Crash Reporter Initialize */
    PLCrashReporterConfig *config = [[PLCrashReporterConfig alloc] initWithSignalHandlerType:PLCrashReporterSignalHandlerTypeMach symbolicationStrategy:PLCrashReporterSymbolicationStrategyNone];
    _crashReporter = [[PLCrashReporter alloc] initWithConfiguration:config];
    
    /* Last Crash Information */
    _crashQueuePath = [NSString stringWithFormat:@"%@/com.urqa.crashreport.queue", documentsDirectory];
    [[NSFileManager defaultManager] createDirectoryAtPath:_crashQueuePath withIntermediateDirectories:YES attributes:nil error:nil];
    NSArray *array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_crashQueuePath error:nil];
    for (NSString *fileName in array)
    {
        if ([fileName hasPrefix:@"Crash_"])
            [_crashQueueFiles addObject:fileName];
    }
    HQALog(@"Crash Queue Files: %lu count(s)", (unsigned long)_crashQueueFiles.count);
    
    [self saveLiveCrash];
    
    /* Crash Reporter Start */
    if (!beingDebugged())
    {
        NSError *error;
        PLCrashReporterCallbacks cb = {
            .version = 0,
            .context = (void *)0x6ACAB6CC,
            .handleSignal = postCrashCallback
        };
        [_crashReporter setCrashCallbacks:&cb];
        
        if (![_crashReporter enableCrashReporterAndReturnError:&error])
        {
#if HQA_ENABLE_ERROR_LOG
            HQALog(@"Error: Could not enable crash reportered due to: %@", error);
#endif
        }
        else
        {
            if (error)
            {
#if HQA_ENABLE_WARNING_LOG
                HQALog(@"Warning: %@", error);
#endif
            }
        }
    }
}

/* Send device session to urqa server.
 */
- (void)sessionUpdate
{
    [_sessionRequester cancelRequest];
    _sessionKey = @"";
    [_sessionRequester sendRequest:^(id object) {
        _sessionKey = [object objectForKey:@"idsession"];
        if(_sessionKey)
            HQALog(@"Session ID: %@", _sessionKey);
    } failure:nil completion:nil];
}

/* Make crash data from NSException, tag, and error rank.
 */
- (BOOL)saveException:(NSException *)exception tag:(NSString *)tag errorRank:(HQAErrorRank)errorRank
{
    NSError *error;
    NSData *reportData = [_crashReporter generateLiveReportAndReturnError:&error];
    if (!reportData)
    {
#if HQA_ENABLE_ERROR_LOG
        HQALog(@"Error: Failed to load crash report data: %@", error);
#endif
        return NO;
    }
    
    HQAExceptionInfo *exceptionInfo = [[HQAExceptionInfo alloc] initWithException:exception];
    [exceptionInfo setTag:tag];
    [exceptionInfo setErrorRank:errorRank];
    
    [self saveCrashInfo:reportData exceptionInfo:exceptionInfo];
    [self sendCrashReporter];
    
    return YES;
}

/* Crash data process in runtime.
 */
- (void)processCrashReporter
{
    HQALog(@"Processing crash report");
    
    [self saveLiveCrash];
    
#if HQA_ENABLE_IMMEDIATELY_SEND
    [self sendCrashReporter];
#endif
}


#pragma mark -
#pragma mark Crash Save

/* Make crash data in live report.
 */
- (void)saveLiveCrash
{
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    if ([_crashReporter hasPendingCrashReport])
    {
        NSFileManager *fm = [NSFileManager defaultManager];
        
        if (![fm createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:nil error:&error])
        {
#if HQA_ENABLE_ERROR_LOG
            HQALog(@"Error: Could not create documents directory: %@", error);
#endif
            return;
        }
        
        NSData *data = [_crashReporter loadPendingCrashReportDataAndReturnError:&error];
        if (data == nil)
        {
#if HQA_ENABLE_ERROR_LOG
            HQALog(@"Error: Failed to load crash report data: %@", error);
#endif
            return;
        }
        
        [self saveCrashInfo:data exceptionInfo:nil];
        
        if (![_crashReporter purgePendingCrashReportAndReturnError:&error])
        {
#if HQA_ENABLE_ERROR_LOG
            HQALog(@"Error: Failed to purge crash report: %@", error);
#endif
        }
    }
}

/* Save current device info to file.
 */
- (void)saveCrashInfo:(NSData *)crashData exceptionInfo:(HQAExceptionInfo *)exception
{
    NSData *data;
    
    NSString *outputFileName = [NSString stringWithFormat:@"Crash_%04ld", (unsigned long)_crashQueueFiles.count];
    NSString *outputPath = [_crashQueuePath stringByAppendingPathComponent:outputFileName];
    if (![crashData writeToFile:outputPath atomically:YES])
    {
#if HQA_ENABLE_ERROR_LOG
        HQALog(@"Error: Failed to write crash report");
#endif
        return;
    }
    else
        [_crashQueueFiles addObject:outputFileName];
    
    data = [_dataParser parseObject:[HQADeviceManager createDeviceReport]];
    outputFileName = [NSString stringWithFormat:@"System_%04lu", (unsigned long)_crashQueueFiles.count - 1];
    outputPath = [_crashQueuePath stringByAppendingPathComponent:outputFileName];
    if (![data writeToFile:outputPath atomically:YES])
    {
#if HQA_ENABLE_WARNING_LOG
        HQALog(@"Warning: Failed to write system report");
#endif
    }
    
    data = [_dataParser parseObject:[_eventPathManager arrayData]];
    outputFileName = [NSString stringWithFormat:@"EventPath_%04lu", (unsigned long)_crashQueueFiles.count - 1];
    outputPath = [_crashQueuePath stringByAppendingPathComponent:outputFileName];
    if (![data writeToFile:outputPath atomically:YES])
    {
#if HQA_ENABLE_WARNING_LOG
        HQALog(@"Warning: Failed to write event path");
#endif
    }
    
    if (exception)
    {
        data = [_dataParser parseObject:exception];
        outputFileName = [NSString stringWithFormat:@"Exc_%04lu", (unsigned long)_crashQueueFiles.count - 1];
        outputPath = [_crashQueuePath stringByAppendingPathComponent:outputFileName];
        if (![data writeToFile:outputPath atomically:YES])
        {
#if HQA_ENABLE_WARNING_LOG
            HQALog(@"Warning: Failed to write exception info");
#endif
        }
    }
    
    HQALog(@"Saved crash report to: Crash_%04lu", (unsigned long)_crashQueueFiles.count - 1);
}


#pragma mark -
#pragma mark Crash Send
/* Send all crash data to urqa server.
 */
- (void)sendCrashReporter
{
    pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
    pthread_mutex_lock(&mutex);
    
    if (!_isSendingCrash)
    {
        if (_crashQueueFiles.count > 0)
        {
            _isSendingCrash = YES;
            
            HQALog(@"Sending crash reports");
            [self sendCrashReporter:[NSNumber numberWithInteger:(_crashQueueFiles.count - 1)]];
        }
    }
    
    pthread_mutex_unlock(&mutex);
}

/* Send crash data to urqa server.
 */
- (BOOL)sendCrashReporter:(NSNumber *)indexNumber
{
    PLCrashReport *reportParser;
    __block long index = [indexNumber integerValue];
    
    NSError *error = nil;
    NSString *crashFile = [_crashQueueFiles objectAtIndex:index];
    NSString *crashPath = [NSString stringWithFormat:@"%@/%@", _crashQueuePath, crashFile];
    NSString *systemPath = [NSString stringWithFormat:@"%@/System_%@", _crashQueuePath, [crashFile substringFromIndex:6]];
    NSString *eventPathPath = [NSString stringWithFormat:@"%@/EventPath_%@", _crashQueuePath, [crashFile substringFromIndex:6]];
    NSString *exceptionPath = [NSString stringWithFormat:@"%@/Exc_%@", _crashQueuePath, [crashFile substringFromIndex:6]];
    NSData *crashData = [NSData dataWithContentsOfFile:crashPath options:NSDataReadingMappedIfSafe error:&error];
    
    void (^fileError)() = ^{
        [[NSFileManager defaultManager] removeItemAtPath:crashPath error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:systemPath error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:eventPathPath error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:exceptionPath error:nil];
        
        [_crashQueueFiles removeObject:crashFile];
    };
    
    if (!crashData)
    {
#if HQA_ENABLE_ERROR_LOG
        HQALog(@"Error: Could not load crash report data due to: %@", error);
#endif
        fileError();
        
        return NO;
    }
    reportParser = [[PLCrashReport alloc] initWithData:crashData error:&error];
    if (!reportParser)
    {
#if HQA_ENABLE_ERROR_LOG
        HQALog(@"Error: Could not parse crash report due to: %@", error);
#endif
        fileError();
        
        return NO;
    }
    crashData = [NSData dataWithContentsOfFile:systemPath options:NSDataReadingMappedIfSafe error:&error];
    HQADeviceInfo *deviceInfo;
    if (!crashData)
    {
#if HQA_ENABLE_WARNING_LOG
        HQALog(@"Warning: Could not load system report data");
#endif
        deviceInfo = [HQADeviceManager createDeviceReport];
    }
    else{
        deviceInfo = [[HQADeviceInfo alloc] initWithData:[_dataParser parseData:crashData]];
    }
    crashData = [NSData dataWithContentsOfFile:eventPathPath options:NSDataReadingMappedIfSafe error:&error];
    NSArray *eventPath;
    if (!crashData)
    {
#if HQA_ENABLE_WARNING_LOG
        HQALog(@"Warning: Could not load event path data");
#endif
        eventPath = @[];
    }
    else
        eventPath = [_dataParser parseData:crashData];
    
    crashData = [NSData dataWithContentsOfFile:exceptionPath options:NSDataReadingMappedIfSafe error:&error];
    HQAExceptionInfo *exceptionInfo;
    if (!crashData)
    {
#if HQA_ENABLE_WARNING_LOG
        HQALog(@"Warning: Could not load exception info data");
#endif
        exceptionInfo = nil;
    }
    else
        exceptionInfo = [[HQAExceptionInfo alloc] initWithData:[_dataParser parseData:crashData]];
    
    HQACrashReport *reportSender = [[HQACrashReport alloc] initWithCrashReport:reportParser deviceInfo:deviceInfo exceptionInfo:exceptionInfo];
    [reportSender setEventPaths:eventPath];
    
    NSString *tag = @"";
    HQAErrorRank errorRank = HQAErrorRankUnhandle;
    if (exceptionInfo)
    {
        tag = exceptionInfo.tag;
        errorRank = exceptionInfo.errorRank;
    }
    
    [[[HQANetworkException alloc] initWithAPIKey:_secretAPIKey andErrorReport:reportSender andErrorRank:errorRank andTag:tag] sendRequest:^(id object) {
#if HQA_ENABLE_SUCCESS_LOG
        HQALog(@"Success, Sended crash reports: %@", crashFile);
#endif
        
        fileError();
        
        if (index > 0)
            [self performSelector:@selector(sendCrashReporter:) withObject:[NSNumber numberWithInteger:(index - 1)]];
        else
        {
            if (_crashQueueFiles.count > 0)
                [self performSelector:@selector(sendCrashReporter:) withObject:[NSNumber numberWithInteger:(_crashQueueFiles.count - 1)]];
            else
                _isSendingCrash = NO;
        }
    } failure:^{
#if HQA_ENABLE_ERROR_LOG
        HQALog(@"Failed, Sending crash reports: %@", crashPath);
#endif
    } completion:nil];
    
    return YES;
}

@end