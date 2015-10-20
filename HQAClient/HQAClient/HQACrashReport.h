//
//  HQACrashReport.h
//  HQAClient
//
//  Created by devholic on 2015. 10. 20..
//  Copyright © 2015년 honeyqa. All rights reserved.
//

#import "HQADataObject.h"

#import "HQADeviceInfo.h"
#import "HQAEventPath.h"
#import "HQAExceptionInfo.h"

@interface HQACrashReport : HQADataObject

@property (nonatomic, retain) HQADeviceInfo          *deviceInfo;
@property (nonatomic, retain) NSArray               *eventPaths;        // UREventPath
@property (nonatomic, retain) NSArray               *stackTrace;
@property (nonatomic, retain) NSString              *exceptionName;
@property (nonatomic, retain) NSString              *exceptionReason;
@property (nonatomic, retain) NSString              *exceptionFunction; // "0x3bbdb000"등 Hex-decimal
@property (nonatomic, retain) NSDate                *datetime;

- (id)initWithCrashReport:(id)crashReport deviceInfo:(HQADeviceInfo *)deviceInfo exceptionInfo:(HQAExceptionInfo *)exceptionInfo;

@end
