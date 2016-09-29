//
//  UIViewController+Menu.m
//  Photopon
//
//  Created by Ante Karin on 29/09/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import "UIViewController+Menu.h"
#import "LeftMenuViewController.h"

@implementation UIViewController (Menu)

- (void)leftMenuClicked {

    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    LeftMenuViewController* leftMenu = (LeftMenuViewController*)[storyBoard instantiateViewControllerWithIdentifier:@"SBLeftMenu"];

    leftMenu.providesPresentationContextTransitionStyle = YES;
    leftMenu.definesPresentationContext = YES;

    [leftMenu onClickHook:^(NSString *menuItem) {


        if ([menuItem isEqualToString:@"notifications"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Goto_Notifications" object:nil];
        }

        if ([menuItem isEqualToString:@"friends"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Goto_Friends" object:nil];
        }

        if ([menuItem isEqualToString:@"coupons"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Goto_Coupons" object:nil];
        }

        if ([menuItem isEqualToString:@"wallet"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Goto_Wallet" object:nil];
        }

        if ([menuItem isEqualToString:@"addphotopon"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Goto_AddPhotopon" object:nil];
        }

        if ([menuItem isEqualToString:@"sentphotopons"]) {
            UIViewController *sentPhotopons = [storyBoard instantiateViewControllerWithIdentifier:@"SBSentPhotopons"];
            [self presentViewController:sentPhotopons animated:true completion:nil];
        }


        if ([menuItem isEqualToString:@"settings"]) {
            UIViewController *settings = [storyBoard instantiateViewControllerWithIdentifier:@"SBSettings"];
            [self presentViewController:settings animated:true completion:nil];

        }

        if ([menuItem isEqualToString:@"register"]) {
            UIViewController* mainCtrl = [storyBoard instantiateViewControllerWithIdentifier:@"SBNumberVerification"];
            [self presentViewController:mainCtrl animated:true completion:nil];

        }


        if ([menuItem isEqualToString:@"signout"]) {
            [PFUser logOut];

            UIViewController* vc = self;

            while (vc) {
                UIViewController* temp = vc.presentingViewController;
                if (!temp.presentedViewController) {
                    [vc dismissViewControllerAnimated:YES completion:^{}];
                    break;
                }
                vc =  temp;
            }

            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Onboarding" bundle:nil];

            UIViewController* onboarding = [storyBoard instantiateViewControllerWithIdentifier:@"WelcomeViewController"];
            [vc presentViewController:onboarding animated:true completion:nil];
        }

    }];



    [leftMenu setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    [self presentViewController:leftMenu animated:NO completion:nil];
    
}

@end
