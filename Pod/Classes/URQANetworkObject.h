//
//  URQANetworkObject.h
//  URQAClient
//
//  Created by devholic on 2015. 10. 20..
//  Copyright © 2015년 honeyqa. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "URQADataObject.h"

#import "URQAResponse.h"
#import "URQANextRequestArgument.h"
#import "URQANextRequest.h"

// Network Process
@interface URQANetworkObject : NSObject
{
@protected
    NSMutableArray      *_arguments;

@protected
    NSString            *requestURL;
    NSString            *requestMethod;
    NSDictionary        *requestHeader;
    URQADataObject        *requestData;
}

@property (nonatomic, getter=_arguments) NSMutableArray *arguments;

- (BOOL)sendRequest:(void (^)(id))success
            failure:(void (^)(void))failure
         completion:(void (^)(void))completion;
- (BOOL)checkSuccess:(URQAResponse *)response;

- (void)cancelRequest;

@end

@interface URQANetworkObject (URQANetworkRequest)

- (NSArray *)nextRequestList;
- (NSInteger)addNextRequest:(URQANextRequest *)request;
- (void)removeNextRequestAtIndex:(NSInteger)index;

@end
