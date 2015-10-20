//
//  HQAExceptionInfo.h
//  HQAClient
//
//  Created by devholic on 2015. 10. 20..
//  Copyright © 2015년 honeyqa. All rights reserved.
//

#import "HQADataObject.h"

#import "./HQADefines.h"

@interface HQAExceptionInfo : HQADataObject

@property (nonatomic, retain) NSString              *exceptionName;
@property (nonatomic, retain) NSString              *exceptionReason;
@property (nonatomic, retain) NSArray               *stackTrace;
@property (nonatomic, retain) NSString              *tag;
@property (nonatomic, assign) HQAErrorRank           errorRank;

- (id)initWithException:(NSException *)exception;

@end