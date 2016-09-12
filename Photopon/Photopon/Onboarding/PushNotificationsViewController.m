//
//  PushNotificationsViewController.m
//  Photopon
//
//  Created by Ante Karin on 11/09/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import "PushNotificationsViewController.h"

@interface  PushNotificationsViewController()

@property (weak, nonatomic) IBOutlet UIButton *pushNotificationButton;


@end

@implementation PushNotificationsViewController

-(void)viewDidLoad {
    [super viewDidLoad];

    self.pushNotificationButton.layer.cornerRadius = 7;
    self.pushNotificationButton.layer.masksToBounds = YES;
}

- (IBAction)pushNotificationsButtonHandler:(id)sender {
    [self enablePushNotification];
}

- (void)enablePushNotification {
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes  categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(pushEnabled) name:@"PushEnabled" object:nil];
}

- (void)pushEnabled {
    [self.delegate userDidAllowPushNotifications];
}

@end
