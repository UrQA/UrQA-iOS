//
//  URQADataObject.h
//  URQAClient
//
//  Created by devholic on 2015. 10. 20..
//  Copyright © 2015년 honeyqa. All rights reserved.
//

#import <Foundation/Foundation.h>

#define IToS(x)         ([NSNumber numberWithLong:(long)(x)])
#define FToS(x)         ([NSNumber numberWithFloat:(float)(x)])
#define DToS(x)         ([NSNumber numberWithDouble:(double)(x)])
#define DInKToS(d,k)    ([d valueForKey:k]?[d valueForKey:k]:@"")
#define DInKToI(d,k)    ([d valueForKey:k]?[[d valueForKey:k] integerValue]:0)
#define DInKToF(d,k)    ([d valueForKey:k]?[[d valueForKey:k] floatValue]:-1.0f)
#define DInKToD(d,k)    ([d valueForKey:k]?[[d valueForKey:k] doubleValue]:-1.0f)
#define DInKToB(d,k)    (DInKToI(d,k) != 0)

@interface URQADataObject : NSObject

- (id)init;
- (id)initWithData:(id)data;        // NSArray or NSDictionary
- (id)objectData;                   // NSArray or NSDictionary

@end
