//
//  URQADeviceManager.h
//  URQAClient
//
//  Created by devholic on 2015. 10. 20..
//  Copyright © 2015년 honeyqa. All rights reserved.
//

#import "URQADeviceInfo.h"

#define CGPointAdd(a,b)     ((CGPoint){(a).x+(b).x,(a).y+(b).y})
#define CGPointSub(a,b)     ((CGPoint){(a).x-(b).x,(a).y-(b).y})
#define CGPointMul(a,b)     ((CGPoint){(a).x*(b).x,(a).y*(b).y})
#define CGSizeAdd(a,b)      ((CGSize){(a).width+(b).width,(a).height+(b).height})
#define CGSizeSub(a,b)      ((CGSize){(a).width-(b).width,(a).height-(b).height})
#define CGSizeMul(a,b)      ((CGSize){(a).width*(b).width,(a).height*(b).height})
#define CGRectAdd(a,b)      ((CGRect){(CGPointAdd((a).origin,(b).origin)),(CGSizeAdd((a).size,(b).size))})
#define CGRectSub(a,b)      ((CGRect){(CGPointSub((a).origin,(b).origin)),(CGSizeSub((a).size,(b).size))})
#define CGRectMul(a,b)      ((CGRect){(CGPointMul((a).origin,(b).origin)),(CGSizeMul((a).size,(b).size))})
#define CGPointOne          ((CGPoint){1,1})
#define CGSizeOne           ((CGSize){1,1})
#define CGRectOne           ((CGRect){1,1,1,1})
#define CGPointVal(a)       ((CGPoint){a,a})
#define CGSizeVal(a)        ((CGSize){a,a})
#define CGRectVal(a)        ((CGRect){a,a,a,a})
#define CGPointRect(a)      ((CGRect){(a),0,0})
#define CGSizeRect(a)       ((CGRect){0,0,(a)})
#define CGSizeToPoint(a)    ((CGPoint){(a).width,(a).height})
#define CGPointToSize(a)    ((CGSize){(a).x,(a).y})

@interface URQADeviceManager : NSObject

+ (URQADeviceInfo *)createDeviceReport;
+ (URQADeviceInfo *)createDeviceReportFromCrashReport:(id)crashReport deviceInfo:(URQADeviceInfo *)deviceInfo;

@end
