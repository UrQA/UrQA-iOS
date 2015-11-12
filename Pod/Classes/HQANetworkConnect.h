//
//  HQANetworkConnect.h
//  HQAClient
//
//  Created by devholic on 2015. 10. 20..
//  Copyright © 2015년 honeyqa. All rights reserved.
//

#import "HQANetworkObject.h"
#import "HQADeviceInfo.h"

@interface HQANetworkConnect : HQANetworkObject

@property (nonatomic, retain) NSString          *APIKey;
@property (nonatomic, retain) HQADeviceInfo      *deviceInfo;

- (id)initWithAPIKey:(NSString *)APIKey deviceInfo:(HQADeviceInfo *)device;

@end
