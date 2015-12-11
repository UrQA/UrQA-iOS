//
//  URQAConfig.h
//  URQAClient
//
//  Created by devholic on 2015. 10. 20..
//  Copyright © 2015년 honeyqa. All rights reserved.
//

#ifndef URQA_ENABLE_CONSOLE_LOG
/**
 * If true, enable console logging.
 */
#   define URQA_ENABLE_CONSOLE_LOG         1
#endif

#ifndef URQA_ENABLE_ERROR_LOG
/**
 * Enable console logging to HoneyQA error.
 *
 * This flag should be enabled URQA_ENABLE_CONSOLE_LOG.
 */
#   define URQA_ENABLE_ERROR_LOG           1
#endif

#ifndef URQA_ENABLE_WARNING_LOG
/**
 * Enable console logging to HoneyQA warning.
 *
 * This flag should be enabled URQA_ENABLE_CONSOLE_LOG.
 */
#   define URQA_ENABLE_WARNING_LOG         1
#endif

#ifndef URQA_ENABLE_SUCCESS_LOG
/**
 * Enable console logging to HoneyQA success.
 *
 * This flag should be enabled URQA_ENABLE_CONSOLE_LOG.
 */
#   define URQA_ENABLE_SUCCESS_LOG         1
#endif

#ifndef URQA_ENABLE_REQUEST_LOG
/**
 * Enable logging on network request data.
 *
 * This flag should be enabled URQA_ENABLE_CONSOLE_LOG.
 */
#   define URQA_ENABLE_REQUEST_LOG         1
#endif

#ifndef URQA_ENABLE_IMMEDIATELY_SEND
/**
 * Enable immediately sends crash-log to HoneyQA server when the app crashes.
 *
 * If this flag is disabled, sends crash-log to HoneyQA server when you start the
 * app again.
 */
#   define URQA_ENABLE_IMMEDIATELY_SEND    1
#endif

// Definition
#define URQA_VERSION            @"1.0.0"
#define URQA_DOMAIN             @"https://api3.honeyqa.io/api/ios"
#define URQA_REQUST_TYPE        @"JSON"

// Console Logging
#if URQA_ENABLE_CONSOLE_LOG
#   define URQALog(format, args...) NSLog(@"[UrQA] " format, ## args)
#else
#   define URQALog(format, args...)
#endif
