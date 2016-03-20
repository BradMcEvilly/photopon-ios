//
//  LoginViewController.m
//  Photopon
//
//  Created by Hayk Hayotsyan on 11/8/15.
//  Copyright (c) 2015 Photopon. All rights reserved.
//

#import "LoginViewController.h"
#import "ParseUI/ParseUI.h"
#import "PhotoponLoginViewController.h"
#import "PhotoponSignupViewController.h"
#import "NumberVerificationViewController.h"
#import "AlertBox.h"
@interface LoginViewController ()

@end



@implementation LoginViewController
{
    LoginViewController* thisPointer;
    BOOL justSignedUp;
}

- (void) gotoView:(NSString*)viewName {
    UIViewController* mainCtrl = [self.storyboard instantiateViewControllerWithIdentifier:viewName];
    [[self topMostController] presentViewController:mainCtrl animated:true completion:nil];
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    PFUser* currentUser = [PFUser currentUser];
    
    NSString* channel = [NSString stringWithFormat:@"User_%@", currentUser.objectId];
    [currentInstallation addUniqueObject:channel forKey:@"channels"];
    [currentInstallation saveInBackground];
    
}

- (void) gotoMainView {
    [self gotoView:@"MainCtrl"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    justSignedUp = NO;
    
}

- (UIViewController*) topMostController {
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    thisPointer = self;
    
    if (![PFUser currentUser]) {
        PhotoponLoginViewController *logInViewController = [[PhotoponLoginViewController alloc] init];
        [logInViewController setDelegate:self];
    
        
        
        PhotoponSignupViewController *signUpViewController = [[PhotoponSignupViewController alloc] init];
        [signUpViewController setDelegate:self];
        
        
        
        [logInViewController setSignUpController:signUpViewController];
        [self presentViewController:logInViewController animated:YES completion:NULL];
    } else {
        if (justSignedUp) {
            justSignedUp = NO;
            [self gotoView: @"SBNumberVerification"];
        } else {
            [self gotoMainView];
        }
    }
    
    
}




-(void)viewWillAppear:(BOOL)animated {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"LoginScreen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    SendGAEvent(@"user_action", @"login_view", @"opened");

}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:NULL];
 //   [self gotoMainView];
    LogDebug(@"User is logged in");
    SendGAEvent(@"user_action", @"login_view", @"logged_in");

    
}


- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:NULL];
    justSignedUp = YES;
    LogDebug(@"User is signed up");
}



- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    
    
    [AlertBox showAlertFor:self
                 withTitle:@"Login error"
               withMessage:@"Invalid username or password"
                leftButton:nil
               rightButton:@"OK"
                leftAction:nil
               rightAction:nil];
    
    
    logInController.logInView.usernameField.text = @"";
    logInController.logInView.passwordField.text = @"";
    
    
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    [self.navigationController popViewControllerAnimated:YES];
}


@end
