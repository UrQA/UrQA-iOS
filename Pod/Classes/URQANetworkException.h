//
//  URQANetworkException.h
//  URQAClient
//
//  Created by devholic on 2015. 10. 20..
//  Copyright © 2015년 honeyqa. All rights reserved.
//

#import "URQANetworkObject.h"
#import "URQACrashReport.h"

@interface URQANetworkException : URQANetworkObject

@property (nonatomic, retain) NSString          *APIKey;
@property (nonatomic, retain) URQACrashReport     *crashReport;
@property (nonatomic, assign) URQAErrorRank       errorRank;
@property (nonatomic, retain) NSString          *tag;

- (id)initWithAPIKey:(NSString *)APIKey andErrorReport:(URQACrashReport *)report andErrorRank:(URQAErrorRank)errorRank andTag:(NSString *)tag;

@end
