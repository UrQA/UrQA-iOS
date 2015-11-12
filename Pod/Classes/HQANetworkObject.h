//
//  HQANetworkObject.h
//  HQAClient
//
//  Created by devholic on 2015. 10. 20..
//  Copyright © 2015년 honeyqa. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HQADataObject.h"

#import "HQAResponse.h"
#import "HQANextRequestArgument.h"
#import "HQANextRequest.h"

// Network Process
@interface HQANetworkObject : NSObject
{
@protected
    NSMutableArray      *_arguments;
    
@protected
    NSString            *requestURL;
    NSString            *requestMethod;
    NSDictionary        *requestHeader;
    HQADataObject        *requestData;
}

@property (nonatomic, getter=_arguments) NSMutableArray *arguments;

- (BOOL)sendRequest:(void (^)(id))success
            failure:(void (^)(void))failure
         completion:(void (^)(void))completion;
- (BOOL)checkSuccess:(HQAResponse *)response;

- (void)cancelRequest;

@end

@interface HQANetworkObject (HQANetworkRequest)

- (NSArray *)nextRequestList;
- (NSInteger)addNextRequest:(HQANextRequest *)request;
- (void)removeNextRequestAtIndex:(NSInteger)index;

@end
