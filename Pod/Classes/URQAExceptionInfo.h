//
//  URQAExceptionInfo.h
//  URQAClient
//
//  Created by devholic on 2015. 10. 20..
//  Copyright © 2015년 honeyqa. All rights reserved.
//

#import "URQADataObject.h"

#import "URQADefines.h"

@interface URQAExceptionInfo : URQADataObject

@property (nonatomic, retain) NSString              *exceptionName;
@property (nonatomic, retain) NSString              *exceptionReason;
@property (nonatomic, retain) NSArray               *stackTrace;
@property (nonatomic, retain) NSString              *tag;
@property (nonatomic, assign) URQAErrorRank           errorRank;

- (id)initWithException:(NSException *)exception;

@end
