//
//  URQADataObjectMerge.h
//  URQAClient
//
//  Created by devholic on 2015. 10. 20..
//  Copyright © 2015년 honeyqa. All rights reserved.
//

#import "URQADataObject.h"

@interface URQADataObjectMerge : URQADataObject

@property (nonatomic, retain) URQADataObject      *object1;
@property (nonatomic, retain) URQADataObject      *object2;

- (id)initWithObject1:(URQADataObject *)obj1 object2:(URQADataObject *)obj2;

@end
