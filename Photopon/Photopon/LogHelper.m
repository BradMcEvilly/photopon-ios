//
//  LogHelper.m
//  Photopon
//
//  Created by Hayk Hayotsyan on 12/8/15.
//  Copyright (c) 2015 Photopon. All rights reserved.
//

#import <Foundation/Foundation.h>


#include "LogHelper.h"
#import <asl.h>



__DEFINE_MAKE_LOG_FUNCTION(ASL_LEVEL_EMERG, LogEmergency)
__DEFINE_MAKE_LOG_FUNCTION(ASL_LEVEL_ALERT, LogAlert)
__DEFINE_MAKE_LOG_FUNCTION(ASL_LEVEL_CRIT, LogCritical)
__DEFINE_MAKE_LOG_FUNCTION(ASL_LEVEL_ERR, LogError)
__DEFINE_MAKE_LOG_FUNCTION(ASL_LEVEL_WARNING, LogWarning)
__DEFINE_MAKE_LOG_FUNCTION(ASL_LEVEL_NOTICE, LogNotice)
__DEFINE_MAKE_LOG_FUNCTION(ASL_LEVEL_INFO, LogInfo)
__DEFINE_MAKE_LOG_FUNCTION(ASL_LEVEL_DEBUG, LogDebug)

