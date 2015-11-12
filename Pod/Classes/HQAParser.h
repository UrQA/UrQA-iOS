//
//  HQAParser.h
//  HQAClient
//
//  Created by devholic on 2015. 10. 20..
//  Copyright © 2015년 honeyqa. All rights reserved.
//

#import "HQADataObject.h"

@interface HQAParser : NSObject

+ (id)defaultParser;
+ (id)parserWithType:(NSString *)parserType;

- (NSData *)parseObject:(id)object;
- (id)parseData:(NSData *)data;

@end
