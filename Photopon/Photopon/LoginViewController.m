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

@interface LoginViewController ()

@end



@implementation LoginViewController
{
    LoginViewController* thisPointer;
}

- (void) gotoMainView {
    UIViewController* mainCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"MainCtrl"];
    [[self topMostController] presentViewController:mainCtrl animated:true completion:nil];
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    PFUser* currentUser = [PFUser currentUser];
    
    NSString* channel = [NSString stringWithFormat:@"User_%@", currentUser.objectId];
    [currentInstallation addUniqueObject:channel forKey:@"channels"];
    [currentInstallation saveInBackground];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (UIViewController*) topMostController {
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}

-(void)accountVerified {
    [self gotoMainView];
}

- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController
           shouldBeginSignUp:(NSDictionary *)info {
    
    
    PFObject *verification = [PFObject objectWithClassName:@"Verifications"];
    NSNumber* code = [NSNumber numberWithInt:arc4random_uniform(900000) + 100000];
    
    verification[@"userName"] = info[@"username"];
    verification[@"code"] = [NSString stringWithFormat:@"%d", [code intValue]];
    
    verification[@"phoneNumber"] = NumbersFromFormattedPhone(info[@"additional"]);
    verification[@"numTried"] = [NSNumber numberWithInt:0];
    
    [verification saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NumberVerificationViewController* verifyPopup = (NumberVerificationViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"SBNumberVerification"];
            
            [verifyPopup initWithCode:code userInfo:info];
            [verifyPopup setTarget:self withAction:@selector(accountVerified)];
            [[self topMostController] presentViewController:verifyPopup animated:YES completion:nil];
            
            

        });

        //        [verifyPopup setFriend:item];
        //        [verifyPopup setFriendViewController:self];
        
//        verifyPopup.providesPresentationContextTransitionStyle = YES;
//        verifyPopup.definesPresentationContext = YES;
        
//        [verifyPopup setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        
    }];
    
    return NO;
};



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
        [self gotoMainView];
    }
    
    
}




-(void)viewWillAppear:(BOOL)animated {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"LoginScreen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
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
    [self gotoMainView];
    LogDebug(@"User is logged in");
    
}


- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:NULL];
    [self gotoMainView];
    LogDebug(@"User is signed up");
}



- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login error"
                                                    message:@"Invalid username or password."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    
    logInController.logInView.usernameField.text = @"";
    logInController.logInView.passwordField.text = @"";
    
    [alert show];
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    [self.navigationController popViewControllerAnimated:YES];
}


@end
