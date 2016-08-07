//
//  UserManager.h
//  Photopon
//
//  Created by Ante Karin on 06/08/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserManager : NSObject

+ (UserManager *)sharedManager;

- (BOOL)userLoggedIn;

+ (BOOL)isFirstTimeUser;

@property (nonatomic, assign) BOOL isFrendInvited;

@end
