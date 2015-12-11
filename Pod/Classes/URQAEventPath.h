//
//  URQAEventPath.h
//  URQAClient
//
//  Created by devholic on 2015. 10. 20..
//  Copyright © 2015년 honeyqa. All rights reserved.
//

#import "URQADataObject.h"

@interface URQAEventPath : URQADataObject

@property (nonatomic, assign) NSInteger         lineNum;
@property (nonatomic, retain) NSDate            *dateTime;
@property (nonatomic, retain) NSString          *prettyFunction;
@property (nonatomic, retain) NSString          *label;

@end
