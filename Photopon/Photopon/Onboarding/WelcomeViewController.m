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

@interface WelcomeViewController ()

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *logoTopConstraint;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *welcomeViewCollection;

@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [AvailabilityManager checkAvailabilityWithLocation:GetCurrentLocation() completion:nil];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    BOOL firstTimeUser = [UserManager isFirstTimeUser];
    if (firstTimeUser) {
        [self animateLogoMovement:^{
            [self animateWelcomeScreensMovement];
        }];
    }
}

#pragma mark - Animations

- (void)animateLogoMovement:(void (^) (void))completion {
    self.logoTopConstraint.constant = 40;
    [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
    }];
}

- (void)animateWelcomeScreensMovement {
    CGFloat delayInterval = 0.4;
    for (UIView *view in self.welcomeViewCollection) {
        CGFloat index = [self.welcomeViewCollection indexOfObject:view];
        [UIView animateWithDuration:1.0 delay:delayInterval * index options:UIViewAnimationOptionCurveEaseInOut animations:^{
            view.alpha = 1.0;
        } completion:nil];
    }
}

#pragma mark - Handlers

- (void)proceedToLogin {
    LoginViewController *loginVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"LoginCtrl"];
    [self presentViewController:loginVC animated:YES completion:nil];
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
