//
//  LogHelper.h
//  Photopon
//
//  Created by Hayk Hayotsyan on 11/8/15.
//  Copyright (c) 2015 Photopon. All rights reserved.
//

#ifndef Photopon_LogHelper_h
#define Photopon_LogHelper_h

#import <asl.h>



static void AddStderrOnce()
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        asl_add_log_file(NULL, STDERR_FILENO);
    });
}



#define __DECLARE_MAKE_LOG_FUNCTION(LEVEL, NAME) \
void NAME (NSString *format, ...);




#define __DEFINE_MAKE_LOG_FUNCTION(LEVEL, NAME) \
void NAME (NSString *format, ...) \
{ \
AddStderrOnce(); \
va_list args; \
va_start(args, format); \
NSString *message = [[NSString alloc] initWithFormat:format arguments:args]; \
asl_log(NULL, NULL, (LEVEL), "%s", [message UTF8String]); \
va_end(args); \
}\






__DECLARE_MAKE_LOG_FUNCTION(ASL_LEVEL_EMERG, LogEmergency)
__DECLARE_MAKE_LOG_FUNCTION(ASL_LEVEL_ALERT, LogAlert)
__DECLARE_MAKE_LOG_FUNCTION(ASL_LEVEL_CRIT, LogCritical)
__DECLARE_MAKE_LOG_FUNCTION(ASL_LEVEL_ERR, LogError)
__DECLARE_MAKE_LOG_FUNCTION(ASL_LEVEL_WARNING, LogWarning)
__DECLARE_MAKE_LOG_FUNCTION(ASL_LEVEL_NOTICE, LogNotice)
__DECLARE_MAKE_LOG_FUNCTION(ASL_LEVEL_INFO, LogInfo)
__DECLARE_MAKE_LOG_FUNCTION(ASL_LEVEL_DEBUG, LogDebug)




#endif
