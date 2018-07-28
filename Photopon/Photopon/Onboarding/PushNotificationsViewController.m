//
//  PushNotificationsViewController.m
//  Photopon
//
//  Created by Ante Karin on 11/09/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import "PushNotificationsViewController.h"
#import "AlertControllerFactory.h"

@interface  PushNotificationsViewController()

@property (weak, nonatomic) IBOutlet UIButton *pushNotificationButton;


@end

@implementation PushNotificationsViewController

-(void)viewDidLoad {
    [super viewDidLoad];

    self.pushNotificationButton.layer.cornerRadius = 7;
    self.pushNotificationButton.layer.masksToBounds = YES;
    
    if([[UIApplication sharedApplication] isRegisteredForRemoteNotifications]){
        [self.pushNotificationButton setTitle:@"Already Enabled" forState:UIControlStateNormal];
        [self.pushNotificationButton setEnabled:NO];
        [self.pushNotificationButton setBackgroundColor:[UIColor lightGrayColor]];
    }
}

- (IBAction)pushNotificationsButtonHandler:(id)sender {
    if ([[UIApplication sharedApplication] isRegisteredForRemoteNotifications]) {
        UIAlertController *alert = [AlertControllerFactory basicAlertWithMessage:@"Push notifications services already enabled, thank you!" completion:^{
            [self.delegate userDidAllowPushNotifications];
        }];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        [self enablePushNotification];
    }
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
