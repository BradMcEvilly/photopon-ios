//
//  PhotoponLoginViewController.m
//  Photopon
//
//  Created by Hayk Hayotsyan on 19/10/15.
//  Copyright © 2015 Photopon. All rights reserved.
//

#import "PhotoponLoginViewController.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@implementation PhotoponLoginViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.logInView setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1]];
    [self.logInView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photopon-logo-black.png"]]];
    
    self.logInView.dismissButton.alpha = 0;
    
    self.signUpController.fields = PFSignUpFieldsUsernameAndPassword | PFSignUpFieldsEmail | PFSignUpFieldsSignUpButton;

   
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    float logoSize = self.logInView.bounds.size.width - 60;
    
    float x = (self.logInView.bounds.size.width - logoSize) / 2;
    
    
    [self.logInView.logo setFrame:CGRectMake(x, 30, logoSize, logoSize / 3)]; // Logo picture is 3:1 proportion

}

- (void)_loginDidFailWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(logInViewController:didFailToLogInWithError:)]) {
        [self.delegate logInViewController:self didFailToLogInWithError:error];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:PFLogInFailureNotification object:self];
    
    
}


@end
