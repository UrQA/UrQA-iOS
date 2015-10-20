//
//  HQADefines.m
//  HQAClient
//
//  Created by devholic on 2015. 10. 19..
//  Copyright © 2015년 honeyqa. All rights reserved.
//

#import "HQADefines.h"

bool isDigit(NSString* testString)
{
    NSCharacterSet *nonDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSRange nond = [testString rangeOfCharacterFromSet:nonDigits];
    if (NSNotFound == nond.location)
        return YES;
    
    return NO;
}
