//
//  HQAResponse.h
//  HQAClient
//
//  Created by devholic on 2015. 10. 20..
//  Copyright © 2015년 honeyqa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HQAResponse : NSObject

@property (nonatomic, assign) NSInteger responseCode;
@property (nonatomic, retain) NSData *responseData;

@end
