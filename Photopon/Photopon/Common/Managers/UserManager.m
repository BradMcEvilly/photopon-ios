//
//  UserManager.m
//  Photopon
//
//  Created by Ante Karin on 06/08/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import "UserManager.h"
#import "AppConstants.h"

@interface UserManager()

@property (nonatomic, assign) BOOL demoUser;

@end

@implementation UserManager

static UserManager *instance;

+ (UserManager *)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[UserManager alloc]init];
    });
    return instance;
}


- (BOOL)userLoggedIn {
    return [PFUser currentUser] ? YES : NO;
}

+ (BOOL)isFirstTimeUser {
    NSNumber *firstTimeUserKey = [[NSUserDefaults standardUserDefaults]objectForKey:PhotoponFirstTimeUserKey];

    if (firstTimeUserKey) {
        return NO;
    } else {
        return YES;
    }
}

@end
