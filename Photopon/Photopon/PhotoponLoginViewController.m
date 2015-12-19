//
//  PhotoponLoginViewController.m
//  Photopon
//
//  Created by Hayk Hayotsyan on 19/10/15.
//  Copyright © 2015 Photopon. All rights reserved.
//

#import "PhotoponLoginViewController.h"
#import "PhoneNumberFormatter.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@implementation PhotoponLoginViewController

{
    PhoneNumberFormatter *myPhoneNumberFormatter;

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.logInView setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1]];
    [self.logInView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photopon-logo.png"]]];
    
    self.logInView.dismissButton.alpha = 0;
    
    
    
    self.signUpController.fields = PFSignUpFieldsUsernameAndPassword | PFSignUpFieldsEmail | PFSignUpFieldsAdditional | PFSignUpFieldsSignUpButton;

    self.signUpController.signUpView.additionalField.keyboardType = UIKeyboardTypePhonePad;
    self.signUpController.signUpView.additionalField.attributedPlaceholder =    [[NSAttributedString alloc] initWithString:@"Phone Number"];

    myPhoneNumberFormatter = [[PhoneNumberFormatter alloc] init];
    
    [self.signUpController.signUpView.additionalField addTarget:self
                                                         action:@selector(autoFormatTextField:)
                                               forControlEvents:UIControlEventEditingChanged];
    
}

- (void)autoFormatTextField:(id)sender {
    
    self.signUpController.signUpView.additionalField.text = [myPhoneNumberFormatter format:self.signUpController.signUpView.additionalField.text withLocale:@"us"];
    
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    float x = (self.logInView.bounds.size.width - 300.0f) / 2;
    [self.logInView.logo setFrame:CGRectMake(x, 30, 300.0f, 100.0f)];

}

- (void)_loginDidFailWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(logInViewController:didFailToLogInWithError:)]) {
        [self.delegate logInViewController:self didFailToLogInWithError:error];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:PFLogInFailureNotification object:self];
    
    
}


@end
