//
//  URQANetworkConnect.h
//  URQAClient
//
//  Created by devholic on 2015. 10. 20..
//  Copyright © 2015년 honeyqa. All rights reserved.
//

#import "URQANetworkObject.h"
#import "URQADeviceInfo.h"

@interface URQANetworkConnect : URQANetworkObject

@property (nonatomic, retain) NSString          *APIKey;
@property (nonatomic, retain) URQADeviceInfo      *deviceInfo;

- (id)initWithAPIKey:(NSString *)APIKey deviceInfo:(URQADeviceInfo *)device;

@end
