//
//  HQANetworkException.h
//  HQAClient
//
//  Created by devholic on 2015. 10. 20..
//  Copyright © 2015년 honeyqa. All rights reserved.
//

#import "HQANetworkObject.h"
#import "HQACrashReport.h"

@interface HQANetworkException : HQANetworkObject

@property (nonatomic, retain) NSString          *APIKey;
@property (nonatomic, retain) HQACrashReport     *crashReport;
@property (nonatomic, assign) HQAErrorRank       errorRank;
@property (nonatomic, retain) NSString          *tag;

- (id)initWithAPIKey:(NSString *)APIKey andErrorReport:(HQACrashReport *)report andErrorRank:(HQAErrorRank)errorRank andTag:(NSString *)tag;

@end
