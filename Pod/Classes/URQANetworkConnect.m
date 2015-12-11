//
//  URQANetworkConnect.m
//  URQAClient
//
//  Created by devholic on 2015. 10. 20..
//  Copyright © 2015년 honeyqa. All rights reserved.
//

#import "URQANetworkConnect.h"

#import "URQAConfig.h"

@interface URQANetworkConnect()

- (void)refreshRequestData;

@end

@implementation URQANetworkConnect

- (void)refreshRequestData
{
    requestData = [[URQADataObject alloc] initWithData:@{@"apikey":_arguments[0],
                                                       @"appversion":[_arguments[1] bundleVersion],
                                                       @"ios_version":[_arguments[1] osVersion],
                                                       @"model":[_arguments[1] machineModel],
                                                       @"carrier_name":[_arguments[1] carrierName],
                                                       @"country_code":[_arguments[1] country] }];
}

- (id)initWithAPIKey:(NSString *)APIKey deviceInfo:(URQADeviceInfo *)device
{
    self = [super init];
    if(self)
    {
        if (!APIKey)
            APIKey = @"";

        [_arguments addObject:(_APIKey = APIKey)];
        [_arguments addObject:(_deviceInfo = device)];
        requestURL = [NSString stringWithFormat:@"%@%@", URQA_DOMAIN, @"/client/session"];
        requestMethod = @"POST";
        requestHeader = nil;
        [self refreshRequestData];
    }

    return self;
}

- (void)setArguments:(NSMutableArray *)arguments
{
    [super setArguments:arguments];
    _APIKey = arguments[0];
    _deviceInfo = arguments[1];

    [self refreshRequestData];
}

- (void)setAPIKey:(NSString *)APIKey
{
    _arguments[0] = (_APIKey = APIKey);
    [self refreshRequestData];
}

- (void)setDeviceInfo:(URQADeviceInfo *)deviceInfo
{
    _arguments[1] = (_deviceInfo = deviceInfo);
    [self refreshRequestData];
}

- (BOOL)checkSuccess:(URQAResponse *)response
{
    if(response.responseCode == 200)
        return YES;

    return NO;
}

@end
