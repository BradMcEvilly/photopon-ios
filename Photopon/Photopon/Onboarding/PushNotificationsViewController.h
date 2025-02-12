//
//  PushNotificationsViewController.h
//  Photopon
//
//  Created by Ante Karin on 11/09/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PushNotificationsDelegate <NSObject>

- (void)userDidAllowPushNotifications;

@end

@interface PushNotificationsViewController : UIViewController

@property (nonatomic, strong)  id<PushNotificationsDelegate> delegate;
- (void)enablePushNotification;

@end
