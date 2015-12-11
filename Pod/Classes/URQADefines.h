//
//  URQADefines.h
//  URQAClient
//
//  Created by devholic on 2015. 10. 19..
//  Copyright © 2015년 honeyqa. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, URQAErrorRank)
{
    URQAErrorRankNothing      = -1,
    URQAErrorRankUnhandle     = 0,
    URQAErrorRankNative       = 1,
    URQAErrorRankCritical     = 2,
    URQAErrorRankMajor        = 3,
    URQAErrorRankMinor        = 4
};

// Clang Diagnostic
#define CLANG_IGNORE_HELPER0(x) #x
#define CLANG_IGNORE_HELPER1(x) CLANG_IGNORE_HELPER0(clang diagnostic ignored x)
#define CLANG_IGNORE_HELPER2(y) CLANG_IGNORE_HELPER1(#y)

#define CLANG_POP _Pragma("clang diagnostic pop")
#define CLANG_IGNORE(x)\
_Pragma("clang diagnostic push");\
_Pragma(CLANG_IGNORE_HELPER2(x))

bool isDigit(NSString* testString);
