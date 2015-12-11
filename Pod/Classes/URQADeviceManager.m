//
//  URQADeviceManager.m
//  URQAClient
//
//  Created by devholic on 2015. 10. 20..
//  Copyright © 2015년 honeyqa. All rights reserved.
//

#import "URQADeviceManager.h"

#import "URQAConfig.h"

#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreLocation/CoreLocation.h>

#import <Reachability/Reachability.h>
#import <CrashReporter/PLCrashReport.h>
#import <CrashReporter/PLCrashReportProcessorInfo.h>

#include <sys/stat.h>
#include <sys/types.h>
#include <sys/sysctl.h>
#include <mach/mach.h>
#include <mach/mach_host.h>
#include <mach-o/dyld.h>
#include <mach-o/loader.h>

#import <UIKit/UIKit.h>

@interface URQADeviceManager()
{
    NSBundle        *_bundle;

    CTCallCenter    *_callCenter;
}

@property (nonatomic, readonly) NSInteger               cpuType;
@property (nonatomic, readonly) NSInteger               cpuSubType;
@property (nonatomic, readonly) NSInteger               cpuProcessorCount;
@property (nonatomic, readonly) NSInteger               cpuLogicalProcessorCount;
@property (nonatomic, readonly) NSInteger               batteryLevel;
@property (nonatomic, readonly) UIDeviceBatteryState    batteryStatus;
@property (nonatomic, readonly) double                  memoryApp;
@property (nonatomic, readonly) double                  memoryFree;
@property (nonatomic, readonly) double                  memoryTotal;
@property (nonatomic, readonly) double                  diskFree;
@property (nonatomic, readonly) double                  diskTotal;
@property (nonatomic, readonly) BOOL                    isEmulator;
@property (nonatomic, readonly) BOOL                    isMemoryWarning;
@property (nonatomic, readonly) CGFloat                 screenDPI;
@property (nonatomic, readonly) CGSize                  screenSize;

@property (nonatomic, readonly) NSString                *callState;

@property (nonatomic, readonly) NSString                *bundleIdentifier;
@property (nonatomic, readonly) NSString                *bundleName;
@property (nonatomic, readonly) NSString                *bundleVersion;
@property (nonatomic, readonly) NSString                *bundleBuildNumber;
@property (nonatomic, readonly) NSString                *machineModel;
@property (nonatomic, readonly) NSString                *osVersion;
@property (nonatomic, readonly) NSString                *osBuildNumber;
@property (nonatomic, readonly) NSString                *language;
@property (nonatomic, readonly) NSString                *carrierName;
@property (nonatomic, readonly) NSString                *isoCountryCode;
@property (nonatomic, readonly) NSString                *buildUUID;

@property (nonatomic, readonly) BOOL                    isPortrait;
@property (nonatomic, readonly) BOOL                    isUseGPS;
@property (nonatomic, readonly) BOOL                    isWifiNetworkOn;
@property (nonatomic, readonly) BOOL                    isMobileNetworkOn;
@property (nonatomic, readonly) BOOL                    isJailbroken;
@property (nonatomic, readonly) BOOL                    isAppCracked;

- (BOOL)detectJailbroken;
- (BOOL)detectAppCracked;

- (BOOL)getSystemNumber:(NSString *)name result:(int *)result;
- (NSString *)getSystemString:(NSString *)name;

@end

@implementation URQADeviceManager

+ (URQADeviceInfo *)createDeviceReport
{
    URQADeviceManager *manager = [self sharedInstance];

    URQADeviceInfo *device = nil;
    if(manager)
    {
        [manager reloadInformation];

        device = [[URQADeviceInfo alloc] init];
        switch ([manager cpuType])
        {
            case CPU_TYPE_VAX:
                device.architecture = @"Vax";
                break;

            case CPU_TYPE_MC680x0:
                device.architecture = @"MC680x0";
                break;

            case CPU_TYPE_X86:
                device.architecture = @"x86";
                break;

            case CPU_TYPE_X86_64:
                device.architecture = @"x64";
                break;

            case CPU_TYPE_MC98000:
                device.architecture = @"MC98000";
                break;

            case CPU_TYPE_HPPA:
                device.architecture = @"HPPA";
                break;

            case CPU_TYPE_ARM:
                device.architecture = @"ARM x86";
                break;

            case CPU_TYPE_ARM64:
                device.architecture = @"ARM x64";
                break;

            case CPU_TYPE_MC88000:
                device.architecture = @"MC88000";
                break;

            case CPU_TYPE_SPARC:
                device.architecture = @"SPARC";
                break;

            case CPU_TYPE_I860:
                device.architecture = @"i860";
                break;

            case CPU_TYPE_POWERPC:
                device.architecture = @"PowerPC x86";
                break;

            case CPU_TYPE_POWERPC64:
                device.architecture = @"PowerPC x64";
                break;

            case CPU_TYPE_ANY:
            default:
                device.architecture = @"Any";
                break;
        }
        device.machineModel = [manager machineModel];
        device.language = [manager language];
        device.bundleVersion = [NSString stringWithFormat:@"%@(%@)", [manager bundleBuildNumber], [manager bundleVersion]];
        device.osVersion = [manager osVersion];
        device.callState = [manager callState];
        device.execName = [manager bundleName];
        device.buildUUID = [manager buildUUID];
        device.isUseGPS = [manager isUseGPS];
        device.isWifiNetworkOn = [manager isWifiNetworkOn];
        device.isMobileNetworkOn = [manager isMobileNetworkOn];
        device.screenWidth = [manager screenSize].width;
        device.screenHeight = [manager screenSize].height;
        device.batteryLevel = [manager batteryLevel];
        device.diskFree = [manager diskFree];
        device.isJailbroken = [manager isJailbroken];
        device.isCracked = [manager detectAppCracked];
        device.memoryApp = [manager memoryApp];
        device.memoryFree = [manager memoryFree];
        device.memoryTotal = [manager memoryTotal];
        device.osBuildNumber = [manager osBuildNumber];
        device.isPortrait = [manager isPortrait];
        device.isMemoryWarning = [manager isMemoryWarning];
        device.country = [manager isoCountryCode];
        device.carrierName = [manager carrierName];
    }
    return device;
}

+ (URQADeviceInfo *)createDeviceReportFromCrashReport:(PLCrashReport *)crashReport deviceInfo:(URQADeviceInfo *)deviceInfo
{
    if (![crashReport isKindOfClass:[PLCrashReport class]])
        return nil;

    URQADeviceInfo *device = [[URQADeviceInfo alloc] init];
    @try
    {
        switch (crashReport.machineInfo.processorInfo.type)
        {
            case CPU_TYPE_VAX:
                device.architecture = @"Vax";
                break;

            case CPU_TYPE_MC680x0:
                device.architecture = @"MC680x0";
                break;

            case CPU_TYPE_X86:
                device.architecture = @"x86";
                break;

            case CPU_TYPE_X86_64:
                device.architecture = @"x64";
                break;

            case CPU_TYPE_MC98000:
                device.architecture = @"MC98000";
                break;

            case CPU_TYPE_HPPA:
                device.architecture = @"HPPA";
                break;

            case CPU_TYPE_ARM:
                device.architecture = @"ARM x86";
                break;

            case CPU_TYPE_ARM64:
                device.architecture = @"ARM x64";
                break;

            case CPU_TYPE_MC88000:
                device.architecture = @"MC88000";
                break;

            case CPU_TYPE_SPARC:
                device.architecture = @"SPARC";
                break;

            case CPU_TYPE_I860:
                device.architecture = @"i860";
                break;

            case CPU_TYPE_POWERPC:
                device.architecture = @"PowerPC x86";
                break;

            case CPU_TYPE_POWERPC64:
                device.architecture = @"PowerPC x64";
                break;

            case CPU_TYPE_ANY:
            default:
                device.architecture = @"Any";
                break;
        }
        device.machineModel = deviceInfo.machineModel;
        device.language = deviceInfo.language;
        device.bundleVersion = deviceInfo.bundleVersion;
        device.osVersion = crashReport.systemInfo.operatingSystemVersion;
        device.callState = deviceInfo.callState;
        device.execName = deviceInfo.execName;
        device.buildUUID = deviceInfo.buildUUID;
        device.isUseGPS = deviceInfo.isUseGPS;
        device.isWifiNetworkOn = deviceInfo.isWifiNetworkOn;
        device.isMobileNetworkOn = deviceInfo.isMobileNetworkOn;
        device.screenWidth = deviceInfo.screenWidth;
        device.screenHeight = deviceInfo.screenHeight;
        device.batteryLevel = deviceInfo.batteryLevel;
        device.diskFree = deviceInfo.diskFree;
        device.isJailbroken = deviceInfo.isJailbroken;
        device.isCracked = deviceInfo.isCracked;
        device.memoryApp = deviceInfo.memoryApp;
        device.memoryFree = deviceInfo.memoryFree;
        device.memoryTotal = deviceInfo.memoryTotal;
        device.osBuildNumber = crashReport.systemInfo.operatingSystemBuild;
        device.isPortrait = deviceInfo.isPortrait;
        device.isMemoryWarning = deviceInfo.isMemoryWarning;
        device.country = deviceInfo.country;
        device.carrierName = deviceInfo.carrierName;
    }
    @catch(NSException *exception)
    {
        device = [[URQADeviceInfo alloc] init];
    }

    return device;
}

+ (URQADeviceManager *)sharedInstance
{
    static URQADeviceManager *manager = nil;

    // It makes singleton object thread-safe
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[URQADeviceManager alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:manager selector:@selector(handleMemoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    });

    return manager;
}

- (id)init
{
    self = [super init];
    if(self)
    {
        _bundle = [NSBundle mainBundle];

        // Call status (over iOS 4.0)
        _callState = @"Disconnected";
        _callCenter = [[CTCallCenter alloc] init];
        [_callCenter setCallEventHandler:^(CTCall *call)
         {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"

             if ([call callState] == CTCallStateConnected)
                 _callState = @"Connected";

             else if ([call callState] == CTCallStateDialing)
                 _callState = @"Dialing";

             else if ([call callState] == CTCallStateIncoming)
                 _callState = @"Incoming";

             else
                 _callState = @"Disconnected";

#pragma clang diagnostic pop
         }];

        [self reloadInformation];
    }

    return self;
}

- (BOOL)reloadInformation
{
    UIDevice *device = [UIDevice currentDevice];

    int retval;

    // CPU
    if([self getSystemNumber:@"hw.cputype" result:&retval])
        _cpuType = retval;
    else
        _cpuType = -1;

    if([self getSystemNumber:@"hw.cpusubtype" result:&retval])
        _cpuSubType = retval;
    else
        _cpuSubType = -1;

    if([self getSystemNumber:@"hw.physicalcpu_max" result:&retval])
        _cpuProcessorCount = retval;
    else
        _cpuProcessorCount = -1;

    if([self getSystemNumber:@"hw.logicalcpu_max" result:&retval])
        _cpuLogicalProcessorCount = retval;
    else
        _cpuLogicalProcessorCount = -1;

    // Battery (over iOS 3.0)
    BOOL lastBatteryMonitoringState = [device isBatteryMonitoringEnabled];
    [device setBatteryMonitoringEnabled:YES];

    _batteryLevel = abs([device batteryLevel] * 100);
    _batteryStatus = [device batteryState];

    [device setBatteryMonitoringEnabled:lastBatteryMonitoringState];

    // Memory
    do
    {
        _memoryApp = -1;
        _memoryFree = -1;
        _memoryTotal = -1;

        mach_port_t host_port;
        struct mach_task_basic_info info;
        mach_msg_type_number_t host_size;
        mach_msg_type_number_t size = sizeof(info);
        vm_size_t pagesize;
        host_port = mach_host_self();
        host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
        host_page_size(host_port, &pagesize);
        vm_statistics_data_t vm_stat;
        if(host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS)
            break;
        if(task_info(mach_task_self(), MACH_TASK_BASIC_INFO, (task_info_t)&info, &size) != KERN_SUCCESS)
            break;

        _memoryApp = info.resident_size / 1048576.0f;
        _memoryFree = vm_stat.free_count * pagesize / 1048576.0f;
        _memoryTotal = (vm_stat.active_count + vm_stat.inactive_count + vm_stat.wire_count) * pagesize / 1048576.0f + _memoryFree;
    } while(0);

    // Disk (over iOS 2.0)
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];

    if(dictionary)
    {
        _diskFree = (([[dictionary objectForKey:NSFileSystemFreeSize] unsignedLongLongValue] * 0.0009765625) * 0.0009765625);
        _diskTotal = (([[dictionary objectForKey: NSFileSystemSize] unsignedLongLongValue] * 0.0009765625) * 0.0009765625);
    }
    else
    {
        _diskFree = -1;
        _diskTotal = -1;
    }

    // is Emulator
    _isEmulator = YES;
    if([self getSystemNumber:@"sysctl.proc_native" result:&retval])
    {
        if(retval == 0)
            _isEmulator = YES;
        else
            _isEmulator = NO;
    }

    // Screen DPI (over iOS 3.2)
    float scale = 1;
    if((BOOL)(([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)]&&[[UIScreen mainScreen] respondsToSelector:@selector(scale)]&&[[UIScreen mainScreen] scale]>1.0)))
        scale = [[UIScreen mainScreen] scale];

    _screenDPI = 160 * scale;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        _screenDPI = 132 * scale;
    else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        _screenDPI = 163 * scale;

    // Screen Size
    _screenSize = CGSizeMul([UIScreen mainScreen].bounds.size, CGSizeVal(scale));

    // Bundle
    _bundleIdentifier = [_bundle bundleIdentifier];
    _bundleName = [[_bundle infoDictionary] objectForKey:(NSString *)kCFBundleNameKey];
    _bundleVersion = [[_bundle infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    _bundleBuildNumber = [[_bundle infoDictionary] objectForKey:@"CFBundleShortVersionString"];

    if(!_bundleIdentifier)
    {
        const char *progname = getprogname();
        if(!progname)
            _bundleIdentifier = @"None";
        else
            _bundleIdentifier = [NSString stringWithUTF8String:progname];
    }
    if(!_bundleVersion)
        _bundleVersion = @"None";
    if(!_bundleBuildNumber)
        _bundleBuildNumber = @"None";

    // Model
    _machineModel = [self getSystemString:@"hw.machine"];
    if(!_machineModel)
        _machineModel = @"None";
    else
    {
        NSDictionary *dict = @{
                               // iPhone
                               @"iPhone1,1": @[@"iPhone 2G",       @"GSM",         @[@"A1203"]],
                               @"iPhone1,2": @[@"iPhone 3G",       @"GSM",         @[@"A1241", @"A13241"]],
                               @"iPhone2,1": @[@"iPhone 3GS",      @"GSM",         @[@"A1303 / A13251"]],
                               @"iPhone3,1": @[@"iPhone 4",        @"GSM",         @[@"A1332"]],
                               @"iPhone3,2": @[@"iPhone 4",        @"GSM Rev A",   @[]],
                               @"iPhone3,3": @[@"iPhone 4",        @"CDMA",        @[@"A1349"]],
                               @"iPhone4,1": @[@"iPhone 4S",       @"GSM+CDMA",    @[@"A1387", @"A14311"]],
                               @"iPhone5,1": @[@"iPhone 5",        @"GSM",         @[@"A1428"]],
                               @"iPhone5,2": @[@"iPhone 5",        @"GSM+CDMA",    @[@"A1429", @"A14421"]],
                               @"iPhone5,3": @[@"iPhone 5C",       @"GSM",         @[@"A1456", @"A1532"]],
                               @"iPhone5,4": @[@"iPhone 5C",       @"Global",      @[@"A1507", @"A1516", @"A1526", @"A1529"]],
                               @"iPhone6,1": @[@"iPhone 5S",       @"GSM",         @[@"A1433", @"A1533"]],
                               @"iPhone6,2": @[@"iPhone 5S",       @"Global",      @[@"A1457", @"A1518", @"A1528", @"A1530"]],
                               @"iPhone7,1": @[@"iPhone 6+",        @"Global",         @[]],
                               @"iPhone7,2": @[@"iPhone 6",        @"Global",      @[]],
                               @"iPhone8,1": @[@"iPhone 6s",        @"Global",         @[]],
                               @"iPhone8,2": @[@"iPhone 6s+",        @"Global",      @[]],

                               // iPod
                               @"iPod1,1":   @[@"iPod touch 1G",   @"",            @[@"A1213"]],
                               @"iPod2,1":   @[@"iPod touch 2G",   @"",            @[@"A1288"]],
                               @"iPod3,1":   @[@"iPod touch 3G",   @"",            @[@"A1318"]],
                               @"iPod4,1":   @[@"iPod touch 4G",   @"",            @[@"A1367"]],
                               @"iPod5,1":   @[@"iPod touch 5G",   @"",            @[@"A1421", @"A1509"]],

                               // iPad
                               @"iPad1,1":   @[@"iPad 1G",         @"WiFi / GSM",  @[@"A1219", @"A1337"]],
                               @"iPad2,1":   @[@"iPad 2",          @"WiFi",        @[@"A1395"]],
                               @"iPad2,2":   @[@"iPad 2",          @"GSM",         @[@"A1396"]],
                               @"iPad2,3":   @[@"iPad 2",          @"CDMA",        @[@"A1397"]],
                               @"iPad2,4":   @[@"iPad 2",          @"WiFi Rev A",  @[@"A1395"]],
                               @"iPad2,5":   @[@"iPad mini 1G",    @"WiFi",        @[@"A1432"]],
                               @"iPad2,6":   @[@"iPad mini 1G",    @"GSM",         @[@"A1454"]],
                               @"iPad2,7":   @[@"iPad mini 1G",    @"GSM+CDMA",    @[@"A1455"]],
                               @"iPad3,1":   @[@"iPad 3",          @"WiFi",        @[@"A1416"]],
                               @"iPad3,2":   @[@"iPad 3",          @"GSM+CDMA",    @[@"A1403"]],
                               @"iPad3,3":   @[@"iPad 3",          @"GSM",         @[@"A1430"]],
                               @"iPad3,4":   @[@"iPad 4",          @"WiFi",        @[@"A1458"]],
                               @"iPad3,5":   @[@"iPad 4",          @"GSM",         @[@"A1459"]],
                               @"iPad3,6":   @[@"iPad 4",          @"GSM+CDMA",    @[@"A1460"]],
                               @"iPad4,1":   @[@"iPad Air",        @"WiFi",        @[@"A1474"]],
                               @"iPad4,2":   @[@"iPad Air",        @"Cellular",    @[@"A1475"]],
                               @"iPad4,3":   @[@"iPad Air",        @"Cellular CN", @[@"A1476"]],
                               @"iPad4,4":   @[@"iPad mini 2G",    @"WiFi",        @[@"A1489"]],
                               @"iPad4,5":   @[@"iPad mini 2G",    @"Cellular",    @[@"A1517"]],

                               // Simulator
                               @"i386":      @[@"Simulator",       @"",            @[]],
                               @"x86_64":    @[@"Simulator",       @"",            @[]],
                               };

        if ([dict objectForKey:_machineModel])
        {
            NSArray *array = [dict objectForKey:_machineModel];
            if ([array[1] isEqualToString:@""])
                _machineModel = array[0];
            else
                _machineModel = [NSString stringWithFormat:@"%@ (%@)", array[0], array[1]];
        }
    }

    // OS Version (over iOS 2.0)
    _osVersion = [[UIDevice currentDevice] systemVersion];

    // OS Build Number
    _osBuildNumber = [self getSystemString:@"kern.osversion"];
    if(!_osBuildNumber)
        _osBuildNumber = @"None";

    // Language (over iOS 2.0)
    _language = [[_bundle preferredLocalizations] objectAtIndex:0];
    if (!_language)
        _language = @"None";

    // Carrier Name / ISO Country Code (over iOS 4.0)
    if(NSClassFromString(@"CTTelephonyNetworkInfo"))
    {
        static CTCarrier *carrierManager = nil;

        if(!carrierManager)
            carrierManager = [[[CTTelephonyNetworkInfo alloc] init] subscriberCellularProvider];

        _carrierName = [carrierManager carrierName];
        _isoCountryCode = [carrierManager isoCountryCode];

        if (!_carrierName)
            _carrierName = @"Not Found";
    }
    else
    {
        _carrierName = @"Not Found";
        _isoCountryCode = nil;
    }
    if (!_isoCountryCode)
    {
        NSString *countryCode = @"None";
        NSTimeZone *timeZone = [NSTimeZone localTimeZone];
        NSString *localizedName = [timeZone localizedName:NSTimeZoneNameStyleShortGeneric locale:[NSLocale systemLocale]];

        NSArray *components = [localizedName componentsSeparatedByString:@"("];
        if ([components count] > 0)
        {
            id lastComponent = [components lastObject];
            if ([lastComponent isKindOfClass:[NSString class]])
            {
                NSString *lastString = lastComponent;
                NSRange whitespaceRange = [lastString rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];

                countryCode = lastString;

                NSRange closingParenthesesRange = [lastString rangeOfString:@")"];
                if (closingParenthesesRange.location != NSNotFound)
                {
                    lastString = [lastString substringToIndex:closingParenthesesRange.location];

                    if (whitespaceRange.location != NSNotFound || [lastString length] > 2)
                    {
                        id firstComponent = [components objectAtIndex:0];
                        if ([firstComponent isKindOfClass:[NSString class]])
                        {
                            NSString *firstString = firstComponent;
                            countryCode = [firstString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                        }
                    }
                }
            }
        }

        _isoCountryCode = countryCode;
    }

    // Build UUID (over iOS 2.0)
    _buildUUID = @"00000000-0000-0000-0000-000000000000";
    for (uint32_t i = 0; i < _dyld_image_count(); i++)
    {
        const struct mach_header *header = _dyld_get_image_header(i);
        if (header->filetype == MH_EXECUTE)
        {
            BOOL is64bit = header->magic == MH_MAGIC_64 || header->magic == MH_CIGAM_64;
            uintptr_t cursor = (uintptr_t)header + (is64bit ? sizeof(struct mach_header_64) : sizeof(struct mach_header));
            const struct segment_command *segmentCommand = NULL;
            for (uint32_t i = 0; i < header->ncmds; i++, cursor += segmentCommand->cmdsize)
            {
                segmentCommand = (struct segment_command *)cursor;
                if (segmentCommand->cmd == LC_UUID)
                {
                    const struct uuid_command *uuidCommand = (const struct uuid_command *)segmentCommand;
                    const uint8_t *uuid = uuidCommand->uuid;

                    _buildUUID = [[NSString stringWithFormat:@"%02X%02X%02X%02X-%02X%02X-%02X%02X-%02X%02X-%02X%02X%02X%02X%02X%02X",
                                   uuid[0], uuid[1], uuid[2], uuid[3],
                                   uuid[4],uuid[5],
                                   uuid[6], uuid[7],
                                   uuid[8], uuid[9],
                                   uuid[10], uuid[11], uuid[12], uuid[13], uuid[14], uuid[15]] lowercaseString];
                    break;
                }
            }
            break;
        }
    }

    // Portrait Detect (over iOS 2.0)
    _isPortrait = UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation);;

    // GPS (over iOS 4.0)
    if(NSClassFromString(@"CLLocationManager"))
    {
        _isUseGPS = (BOOL)[NSClassFromString(@"CLLocationManager") performSelector:@selector(locationServicesEnabled)];
        //        switch ([CLLocationManager authorizationStatus])
        //        {
        //            case kCLAuthorizationStatusNotDetermined:
        //            case kCLAuthorizationStatusRestricted:
        //            case kCLAuthorizationStatusDenied:
        //                _isUseGPS = NO;
        //                break;
        //
        //            case kCLAuthorizationStatusAuthorizedAlways:
        //            case kCLAuthorizationStatusAuthorizedWhenInUse:
        //            default:
        //                _isUseGPS = [CLLocationManager locationServicesEnabled];
        //                break;
        //        }
    }
    else
        _isUseGPS = NO;

    // Wifi/Mobile Network Detect (over iOS 2.0)
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reach currentReachabilityStatus];
    switch(status)
    {
        case NotReachable:
            _isWifiNetworkOn = NO;
            _isMobileNetworkOn = NO;
            break;

        case ReachableViaWiFi:
            _isWifiNetworkOn = YES;
            _isMobileNetworkOn = NO;
            break;

        case ReachableViaWWAN:
            _isWifiNetworkOn = NO;
            _isMobileNetworkOn = YES;
            break;

        default:
            _isWifiNetworkOn = NO;
            _isMobileNetworkOn = NO;
            break;
    }

    // Jailbroken
    _isJailbroken = [self detectJailbroken];

    // App cracked
    _isAppCracked = [self detectAppCracked];

    return YES;
}

- (void)handleMemoryWarning:(NSNotification *)notification
{
    _isMemoryWarning = YES;
}

- (BOOL)detectJailbroken
{
#if !TARGET_IPHONE_SIMULATOR
    //Apps and System check list
    BOOL isDirectory;
    NSArray *filePathArray = [NSArray arrayWithObjects:
                              @"/Applications/Cydia.app",
                              @"/Applications/FakeCarrier.app",
                              @"/Applications/Icy.app",
                              @"/Applications/IntelliScreen.app",
                              @"/Applications/MxTube.app",
                              @"/Applications/RockApp.app",
                              @"/Applications/SBSettings.app",
                              @"/Applications/WinterBoard.app",
                              @"/private/var/tmp/cydia.log",
                              @"/usr/binsshd",
                              @"/usr/sbinsshd",
                              @"/usr/libexec/sftp-server",
                              @"/System/Library/LaunchDaemons/com.ikey.bbot.plist",
                              @"/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist",
                              @"/Library/MobileSubstrate/MobileSubstrate.dylib",
                              @"/var/log/syslog",
                              @"/bin/bash",
                              @"/bin/sh",
                              @"/etc/ssh/sshd_config",
                              @"/usr/libexec/ssh-keysign",
                              nil];
    NSArray *directoryArray =[NSArray arrayWithObjects:
                              @"/private/var/lib/apt/",
                              @"/private/var/lib/cydia/",
                              @"/private/var/mobileLibrary/SBSettingsThemes/",
                              @"/private/var/stash/",
                              @"/usr/libexec/cydia/",
                              @"/var/cache/apt/",
                              @"/var/lib/apt/",
                              @"/var/lib/cydia/",
                              @"/etc/apt/",
                              nil];

    for(NSString *existsPath in filePathArray)
        if([[NSFileManager defaultManager] fileExistsAtPath:existsPath])
            return YES;

    for(NSString *existsDirectory in directoryArray)
        if([[NSFileManager defaultManager] fileExistsAtPath:existsDirectory isDirectory:&isDirectory])
            return YES;

    // SandBox Integrity Check
    int pid = fork();
    if(!pid)
        exit(0);

    if(pid >= 0)
        return YES;

    // Symbolic link verification
    struct stat s;
    if(lstat("/Applications", &s) ||
       lstat("/var/stash/Library/Ringstones", &s) ||
       lstat("/var/stash/Library/Wallpaper", &s) ||
       lstat("/var/stash/usr/include", &s) ||
       lstat("/var/stash/usr/libexec", &s) ||
       lstat("/var/stash/usr/share", &s) ||
       lstat("/var/stash/usr/arm-apple-darwin9", &s))
    {
        if(s.st_mode & S_IFLNK)
            return YES;
    }

    // Try to write file in private
    NSError *error;
    [[NSString stringWithFormat:@"Jailbreak test string"]
     writeToFile:@"/private/test_jb.txt"
     atomically:YES
     encoding:NSUTF8StringEncoding error:&error];

    if(!error)
        return YES;
    else
        [[NSFileManager defaultManager] removeItemAtPath:@"/private/test_jb.txt" error:nil];
#endif

    return NO;
}

- (BOOL)detectAppCracked
{
#if !TARGET_IPHONE_SIMULATOR
    NSBundle *bundle = [NSBundle mainBundle];
    NSString* bundlePath = [bundle bundlePath];
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL fileExists;

    //Check to see if the app is running on root
    int root = getgid();
    if(root <= 10)
        return YES;

    //Checking for identity signature
    char symCipher[] = { '(', 'H', 'Z', '[', '9', '{', '+', 'k', ',', 'o', 'g', 'U', ':', 'D', 'L', '#', 'S', ')', '!', 'F', '^', 'T', 'u', 'd', 'a', '-', 'A', 'f', 'z', ';', 'b', '\'', 'v', 'm', 'B', '0', 'J', 'c', 'W', 't', '*', '|', 'O', '\\', '7', 'E', '@', 'x', '"', 'X', 'V', 'r', 'n', 'Q', 'y', '>', ']', '$', '%', '_', '/', 'P', 'R', 'K', '}', '?', 'I', '8', 'Y', '=', 'N', '3', '.', 's', '<', 'l', '4', 'w', 'j', 'G', '`', '2', 'i', 'C', '6', 'q', 'M', 'p', '1', '5', '&', 'e', 'h' };
    char csignid[] = "V.NwY2*8YwC.C1";
    for(int i = 0; i < strlen(csignid); i ++)
    {
        for(int j = 0; j < sizeof(symCipher); j ++)
        {
            if(csignid[i] == symCipher[j])
            {
                csignid[i] = j + 0x21;
                break;
            }
        }
    }
    NSString* signIdentity = [[NSString alloc] initWithCString:csignid encoding:NSUTF8StringEncoding];

    NSDictionary *info = [bundle infoDictionary];
    if([info objectForKey:signIdentity])
        return YES;

    // Check if the below .plist files exists in the app bundle
    fileExists = [manager fileExistsAtPath:([NSString stringWithFormat:@"%@/%@", bundlePath, @"_CodeSignature"])];
    if(!fileExists)
        return YES;

    fileExists = [manager fileExistsAtPath:([NSString stringWithFormat:@"%@/%@", bundlePath, @"ResourceRules.plist"])];
    if(!fileExists)
        return YES;


    fileExists = [manager fileExistsAtPath:([NSString stringWithFormat:@"%@/%@", bundlePath, @"SC_Info"])];
    if(!fileExists)
        return YES;

    //Check if the info.plist and exectable files have been modified
    NSDate* pkgInfoModifiedDate = [[manager attributesOfItemAtPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"PkgInfo"] error:nil] fileModificationDate];

    NSString* infoPath = [NSString stringWithFormat:@"%@/%@", bundlePath, @"Info.plist"];
    NSDate* infoModifiedDate = [[manager attributesOfItemAtPath:infoPath error:nil] fileModificationDate];
    if([infoModifiedDate timeIntervalSinceReferenceDate] > [pkgInfoModifiedDate timeIntervalSinceReferenceDate])
        return YES;

    NSString* appPathName = [NSString stringWithFormat:@"%@/%@", bundlePath, [[bundle infoDictionary] objectForKey:@"CFBundleDisplayName"]];
    NSDate* appPathNameModifiedDate = [[manager attributesOfItemAtPath:appPathName error:nil] fileModificationDate];
    if([appPathNameModifiedDate timeIntervalSinceReferenceDate] > [pkgInfoModifiedDate timeIntervalSinceReferenceDate])
        return YES;
#endif

    return NO;
}

- (BOOL)getSystemNumber:(NSString *)name result:(int *)result
{
    size_t len = sizeof(*result);

    if(!sysctlbyname([name UTF8String], result, &len, NULL, 0))
        return false;

    return YES;
}

- (NSString *)getSystemString:(NSString *)name
{
    char result[1024];
    size_t result_len = 1024;

    if(sysctlbyname([name UTF8String], &result, &result_len, NULL, 0) < 0)
        return nil;

    return [NSString stringWithUTF8String:result];
}

@end
