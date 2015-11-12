//
//  HQADeviceInfo.m
//  HQAClient
//
//  Created by devholic on 2015. 10. 20..
//  Copyright © 2015년 honeyqa. All rights reserved.
//

#import "HQADeviceInfo.h"

@implementation HQADeviceInfo

- (id)init
{
    self = [super init];
    if(self)
    {
        _architecture       = @"None";
        _machineModel       = @"None";
        _language           = @"None";
        _bundleVersion      = @"None";
        _osVersion          = @"None";
        _callState          = @"None";
        _execName           = @"None";
        _buildUUID          = @"None";
        _isUseGPS           = NO;
        _isWifiNetworkOn    = NO;
        _isMobileNetworkOn  = NO;
        _screenWidth        = -1.0f;
        _screenHeight       = -1.0f;
        _batteryLevel       = -1;
        _diskFree           = -1.0f;
        _isJailbroken       = NO;
        _isCracked          = NO;
        _memoryApp          = -1.0f;
        _memoryFree         = -1.0f;
        _memoryTotal        = -1.0f;
        _osBuildNumber      = @"None";
        _isPortrait         = NO;
        _isMemoryWarning    = NO;
        _country            = @"None";
        _carrierName        = @"Not Found";
    }
    
    return self;
}

- (id)initWithData:(id)data
{
    self = [super initWithData:data];
    if(self)
    {
        _architecture       = DInKToS(data, @"architecture");
        _machineModel       = DInKToS(data, @"device");
        _language           = DInKToS(data, @"locale");
        _bundleVersion      = DInKToS(data, @"appversion");
        _osVersion          = DInKToS(data, @"osversion");
        _callState          = DInKToS(data, @"callstate");
        _execName           = DInKToS(data, @"exename");
        _buildUUID          = DInKToS(data, @"buildid");
        _isUseGPS           = DInKToB(data, @"gpson");
        _isWifiNetworkOn    = DInKToB(data, @"wifion");
        _isMobileNetworkOn  = DInKToB(data, @"mobileon");
        _screenWidth        = DInKToF(data, @"scrwidth");
        _screenHeight       = DInKToF(data, @"scrheight");
        _batteryLevel       = DInKToI(data, @"batterylevel");
        _diskFree           = DInKToF(data, @"availsdcard");
        _isJailbroken       = DInKToB(data, @"Jailbreak");
        _isCracked          = DInKToB(data, @"Cracked");
        _memoryApp          = DInKToF(data, @"appmemusage");
        _memoryFree         = DInKToF(data, @"appmemfree");
        _memoryTotal        = DInKToF(data, @"appmemtotal");
        _osBuildNumber      = DInKToS(data, @"kernelversion");
        _isPortrait         = !DInKToB(data,@"scrorientation");
        _isMemoryWarning    = DInKToB(data, @"sysmemlow");
        _country            = DInKToS(data, @"country");
        _carrierName        = DInKToS(data, @"carrier");
    }
    
    return self;
}

- (id)objectData
{
    return @{@"architecture"    : _architecture,
             @"device"          : _machineModel,
             @"locale"          : _language,
             @"appversion"      : _bundleVersion,
             @"osversion"       : _osVersion,
             @"callstate"       : _callState,
             @"exename"         : _execName,
             @"buildid"         : _buildUUID,
             @"gpson"           : IToS(_isUseGPS),
             @"wifion"          : IToS(_isWifiNetworkOn),
             @"mobileon"        : IToS(_isMobileNetworkOn),
             @"scrwidth"        : FToS(_screenWidth),
             @"scrheight"       : FToS(_screenHeight),
             @"batterylevel"    : IToS(_batteryLevel),
             @"availsdcard"     : FToS(_diskFree),
             @"Jailbreak"       : IToS(_isJailbroken),
             @"Cracked"         : IToS(_isCracked),
             @"appmemusage"     : FToS(_memoryApp),
             @"appmemfree"      : FToS(_memoryFree),
             @"appmemtotal"     : FToS(_memoryTotal),
             @"kernelversion"   : _osBuildNumber,
             @"scrorientation"  : IToS(!_isPortrait),
             @"sysmemlow"       : IToS(_isMemoryWarning),
             @"country"         : _country,
             @"carrier"         : _carrierName};
}

@end
