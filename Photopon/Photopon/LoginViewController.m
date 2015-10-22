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

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}



- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (![PFUser currentUser]) {
        PhotoponLoginViewController *logInViewController = [[PhotoponLoginViewController alloc] init];
        [logInViewController setDelegate:self];
    
        
        
        PhotoponSignupViewController *signUpViewController = [[PhotoponSignupViewController alloc] init];
        [signUpViewController setDelegate:self];
        
        
        
        [logInViewController setSignUpController:signUpViewController];
        [self presentViewController:logInViewController animated:YES completion:NULL];
    } else {
        UIViewController* mainCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"MainCtrl"];
        [self presentViewController:mainCtrl animated:true completion:nil];
    }
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

    UIViewController* mainCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"MainCtrl"];
    [self presentViewController:mainCtrl animated:true completion:nil];
  
    LogDebug(@"User is logged in");
    
}


- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    UIViewController* mainCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"MainCtrl"];
    [self presentViewController:mainCtrl animated:true completion:nil];
    
    LogDebug(@"User is signed up");
}



- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    LogError(@"Failed to log in...");
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    [self.navigationController popViewControllerAnimated:YES];
}


@end
