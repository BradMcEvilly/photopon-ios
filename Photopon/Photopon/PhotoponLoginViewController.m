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
    
    self.signUpController.fields = PFSignUpFieldsUsernameAndPassword | PFSignUpFieldsSignUpButton;
    self.signUpController.emailAsUsername = YES;

//    [self setupSkipButton];
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

#pragma mark - Skip

- (void)setupSkipButton {
    UIButton *skipButton = [[UIButton alloc]init];
    [skipButton setTitle:@"Skip login" forState:UIControlStateNormal];
    [self.view addSubview:skipButton];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-50-[button]" options:NSLayoutFormatAlignAllTop metrics:nil views:@{@"button": skipButton}]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:skipButton attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    skipButton.translatesAutoresizingMaskIntoConstraints = NO;
}

@end
