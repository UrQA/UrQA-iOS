//
//  HQADataObjectMerge.h
//  HQAClient
//
//  Created by devholic on 2015. 10. 20..
//  Copyright © 2015년 honeyqa. All rights reserved.
//

#import "HQADataObject.h"

@interface HQADataObjectMerge : HQADataObject

@property (nonatomic, retain) HQADataObject      *object1;
@property (nonatomic, retain) HQADataObject      *object2;

- (id)initWithObject1:(HQADataObject *)obj1 object2:(HQADataObject *)obj2;

@end
