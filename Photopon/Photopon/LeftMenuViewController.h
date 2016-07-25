//
//  LeftMenuViewController.h
//  Photopon
//
//  Created by Hayk Hayotsyan on 15/12/15.
//  Copyright © 2015 Photopon. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^MenuHookType)(NSString* menuItem);


@interface LeftMenuViewController : UIViewController


@property (weak, nonatomic) IBOutlet UIView *menuView;
@property (strong, nonatomic) IBOutlet UIView *mainView;



@property (weak, nonatomic) IBOutlet UIView *notificationItem;
@property (weak, nonatomic) IBOutlet UIView *friendsItem;
@property (weak, nonatomic) IBOutlet UIView *couponsItem;
@property (weak, nonatomic) IBOutlet UIView *walletItem;
@property (weak, nonatomic) IBOutlet UIView *settingsItem;
@property (weak, nonatomic) IBOutlet UIView *signoutItem;
@property (weak, nonatomic) IBOutlet UIView *addPhotoponItem;
@property (weak, nonatomic) IBOutlet UIView *sentPhotopons;


- (void) onClickHook:(MenuHookType)hook;

@end
