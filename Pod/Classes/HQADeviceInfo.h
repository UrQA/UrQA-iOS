//
//  HQADeviceInfo.h
//  HQAClient
//
//  Created by devholic on 2015. 10. 20..
//  Copyright © 2015년 honeyqa. All rights reserved.
//

#import "HQADataObject.h"

@interface HQADeviceInfo : HQADataObject

@property (nonatomic, retain) NSString          *architecture;
@property (nonatomic, retain) NSString          *machineModel;
@property (nonatomic, retain) NSString          *language;
@property (nonatomic, retain) NSString          *bundleVersion;
@property (nonatomic, retain) NSString          *osVersion;
@property (nonatomic, retain) NSString          *callState;
@property (nonatomic, retain) NSString          *execName;
@property (nonatomic, retain) NSString          *buildUUID;
@property (nonatomic, assign) BOOL              isUseGPS;
@property (nonatomic, assign) BOOL              isWifiNetworkOn;
@property (nonatomic, assign) BOOL              isMobileNetworkOn;
@property (nonatomic, assign) float             screenWidth;
@property (nonatomic, assign) float             screenHeight;
@property (nonatomic, assign) NSInteger         batteryLevel;
@property (nonatomic, assign) double            diskFree;
@property (nonatomic, assign) BOOL              isJailbroken;
@property (nonatomic, assign) BOOL              isCracked;
@property (nonatomic, assign) double            memoryApp;
@property (nonatomic, assign) double            memoryFree;
@property (nonatomic, assign) double            memoryTotal;
@property (nonatomic, retain) NSString          *osBuildNumber;
@property (nonatomic, assign) BOOL              isPortrait;
@property (nonatomic, assign) BOOL              isMemoryWarning;
@property (nonatomic, retain) NSString          *country;
@property (nonatomic, retain) NSString          *carrierName;

@end
