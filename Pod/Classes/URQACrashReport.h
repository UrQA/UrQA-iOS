//
//  URQACrashReport.h
//  URQAClient
//
//  Created by devholic on 2015. 10. 20..
//  Copyright © 2015년 honeyqa. All rights reserved.
//

#import "URQADataObject.h"

#import "URQADeviceInfo.h"
#import "URQAEventPath.h"
#import "URQAExceptionInfo.h"

@interface URQACrashReport : URQADataObject

@property (nonatomic, retain) URQADeviceInfo          *deviceInfo;
@property (nonatomic, retain) NSArray               *eventPaths;        // UREventPath
@property (nonatomic, retain) NSArray               *stackTrace;
@property (nonatomic, retain) NSString              *exceptionName;
@property (nonatomic, retain) NSString              *exceptionReason;
@property (nonatomic, retain) NSString              *exceptionFunction; // "0x3bbdb000"등 Hex-decimal
@property (nonatomic, retain) NSDate                *datetime;

- (id)initWithCrashReport:(id)crashReport deviceInfo:(URQADeviceInfo *)deviceInfo exceptionInfo:(URQAExceptionInfo *)exceptionInfo;

@end
