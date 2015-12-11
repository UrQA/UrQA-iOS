//
//  URQAEventPathManager.h
//  URQAClient
//
//  Created by devholic on 2015. 10. 20..
//  Copyright © 2015년 honeyqa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface URQAEventPathManager : NSObject

@property (readonly) NSArray            *eventPath;

+ (URQAEventPathManager *)sharedInstance;

- (BOOL)createEventPath:(NSInteger)step lineNumber:(NSInteger)linenum;
- (BOOL)createEventPath:(NSInteger)step lineNumber:(NSInteger)linenum label:(NSString *)label;
- (BOOL)createEventPath:(NSInteger)step lineNumber:(NSInteger)linenum prettyFunction:(NSString *)prettyFunction label:(NSString *)label;
- (void)removeAllObjects;
- (NSArray *)arrayData;

@end
