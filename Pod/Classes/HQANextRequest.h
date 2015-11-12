//
//  HQANextRequest.h
//  HQAClient
//
//  Created by devholic on 2015. 10. 20..
//  Copyright © 2015년 honeyqa. All rights reserved.
//

#import "HQANextRequestArgument.h"

@interface HQANextRequest : NSObject

@property (nonatomic, assign) Class                     requestClass;
@property (nonatomic, retain) NSArray                   *arguments;

@end
