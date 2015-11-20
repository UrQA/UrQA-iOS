//
//  HQAConfig.h
//  HQAClient
//
//  Created by devholic on 2015. 10. 20..
//  Copyright © 2015년 honeyqa. All rights reserved.
//

#ifndef HQA_ENABLE_CONSOLE_LOG
/**
 * If true, enable console logging.
 */
#   define HQA_ENABLE_CONSOLE_LOG         1
#endif

#ifndef HQA_ENABLE_ERROR_LOG
/**
 * Enable console logging to HoneyQA error.
 *
 * This flag should be enabled HQA_ENABLE_CONSOLE_LOG.
 */
#   define HQA_ENABLE_ERROR_LOG           1
#endif

#ifndef HQA_ENABLE_WARNING_LOG
/**
 * Enable console logging to HoneyQA warning.
 *
 * This flag should be enabled HQA_ENABLE_CONSOLE_LOG.
 */
#   define HQA_ENABLE_WARNING_LOG         1
#endif

#ifndef HQA_ENABLE_SUCCESS_LOG
/**
 * Enable console logging to HoneyQA success.
 *
 * This flag should be enabled HQA_ENABLE_CONSOLE_LOG.
 */
#   define HQA_ENABLE_SUCCESS_LOG         1
#endif

#ifndef HQA_ENABLE_REQUEST_LOG
/**
 * Enable logging on network request data.
 *
 * This flag should be enabled HQA_ENABLE_CONSOLE_LOG.
 */
#   define HQA_ENABLE_REQUEST_LOG         1
#endif

#ifndef HQA_ENABLE_IMMEDIATELY_SEND
/**
 * Enable immediately sends crash-log to HoneyQA server when the app crashes.
 *
 * If this flag is disabled, sends crash-log to HoneyQA server when you start the
 * app again.
 */
#   define HQA_ENABLE_IMMEDIATELY_SEND    1
#endif

// Definition
#define HQA_VERSION            @"0.1.4"
#define HQA_DOMAIN             @"https://api2.honeyqa.io/api/ios"
#define HQA_REQUST_TYPE        @"JSON"

// Console Logging
#if HQA_ENABLE_CONSOLE_LOG
#   define HQALog(format, args...) NSLog(@"[HoneyQA] " format, ## args)
#else
#   define HQALog(format, args...)
#endif
