//
//  UserManager.m
//  Photopon
//
//  Created by Ante Karin on 06/08/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import "UserManager.h"
#import "AppConstants.h"

@implementation UserManager

+ (BOOL)isFirstTimeUser {
    NSNumber *firstTimeUserKey = [[NSUserDefaults standardUserDefaults]objectForKey:PhotoponFirstTimeUserKey];

    if (firstTimeUserKey) {
        return NO;
    } else {
        return YES;
    }
}

@end
