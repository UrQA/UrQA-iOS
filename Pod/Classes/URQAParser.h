//
//  URQAParser.h
//  URQAClient
//
//  Created by devholic on 2015. 10. 20..
//  Copyright © 2015년 honeyqa. All rights reserved.
//

#import "URQADataObject.h"

@interface URQAParser : NSObject

+ (id)defaultParser;
+ (id)parserWithType:(NSString *)parserType;

- (NSData *)parseObject:(id)object;
- (id)parseData:(NSData *)data;

@end
