//
//  URQANextRequestArgument.h
//  URQAClient
//
//  Created by devholic on 2015. 10. 20..
//  Copyright © 2015년 honeyqa. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    ARGUMENT_TYPE_PREVIOUS_INDEX,
    ARGUMENT_TYPE_RESPONSE_VALUE,
    ARGUMENT_TYPE_RESPONSE_ALL_OBJECT
} ARGUMENT_TYPE;

@interface URQANextRequestArgument : NSObject

@property (nonatomic, retain) NSString      *argumentName;
@property (nonatomic, assign) ARGUMENT_TYPE argumentType;

@end
