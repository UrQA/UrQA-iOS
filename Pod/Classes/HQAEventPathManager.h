//
//  HQAEventPathManager.h
//  HQAClient
//
//  Created by devholic on 2015. 10. 20..
//  Copyright © 2015년 honeyqa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HQAEventPathManager : NSObject

@property (readonly) NSArray            *eventPath;

+ (HQAEventPathManager *)sharedInstance;

- (BOOL)createEventPath:(NSInteger)step lineNumber:(NSInteger)linenum;
- (BOOL)createEventPath:(NSInteger)step lineNumber:(NSInteger)linenum label:(NSString *)label;
- (BOOL)createEventPath:(NSInteger)step lineNumber:(NSInteger)linenum prettyFunction:(NSString *)prettyFunction label:(NSString *)label;
- (void)removeAllObjects;
- (NSArray *)arrayData;

@end
