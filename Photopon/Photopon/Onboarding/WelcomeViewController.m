//
//  WelcomeViewController.m
//  Photopon
//
//  Created by Ante Karin on 06/08/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import "WelcomeViewController.h"
#import "UserManager.h"
#import "LoginViewController.h"
#import "AvailabilityManager.h"
#import "Helper.h"
#import "AlertBox.h"
#import "MainController.h"

@interface WelcomeViewController ()

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *logoMidConstraint;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *welcomeViewCollection;

@property (nonatomic, assign) BOOL shouldCheckUser;

@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.shouldCheckUser = YES;
    [AvailabilityManager checkAvailabilityWithLocation:GetCurrentLocation() completion:nil];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (self.shouldCheckUser) {
        self.shouldCheckUser = NO;
        BOOL firstTimeUser = [UserManager isFirstTimeUser];
        if (![[UserManager sharedManager]userLoggedIn]) {
            [self showOnboarding];
        } else {
            [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
            [self proceedToLogin];
        }
    }
}

#pragma mark - Animations

- (void)animateLogoMovement:(void (^) (void))completion {
    self.logoMidConstraint.constant -= 60;
    [UIView animateWithDuration:0.7 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
    }];
}

- (void)animateWelcomeScreensMovement {
    CGFloat delayInterval = 0.3;
    for (UIView *view in self.welcomeViewCollection) {
        CGFloat index = [self.welcomeViewCollection indexOfObject:view];
        [UIView animateWithDuration:1.0 delay:delayInterval * index options:UIViewAnimationOptionCurveEaseInOut animations:^{
            view.alpha = 0.7;
        } completion:nil];
    }
}

#pragma mark - Handlers

- (void)proceedToLogin {
    /*
    LoginViewController *loginVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"LoginCtrl"];
    [self presentViewController:loginVC animated:YES completion:nil];
     */
    MainController *mainVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"MainCtrl"];
    [self presentViewController:mainVC animated:YES completion:nil];
    
    
}

- (void)showOnboarding {
    UINavigationController *onboardingNV = [[UIStoryboard storyboardWithName:@"Onboarding" bundle:nil]instantiateViewControllerWithIdentifier:@"OnboardingNavigationController"];
    [self presentViewController:onboardingNV animated:YES completion:nil];
}

- (IBAction)sawPostcardHandler {
    if ([AvailabilityManager photoponAvailable]) {
        [self proceedToLogin];
        SendGAEvent(@"user_action", @"welcome_screen", @"saw_a_postcard");
    } else {
        [AlertBox showAlertFor:self withTitle:@"Photopon" withMessage:@"Photopon is currently not available in this area" leftButton:@"OK" rightButton:nil leftAction:nil rightAction:nil];
    }
}

- (IBAction)fromFriendHandler {
    [UserManager sharedManager].isFrendInvited = YES;
    SendGAEvent(@"user_action", @"welcome_screen", @"received_photopon_from_friend");
    [self proceedToLogin];

}

@end
