//
//  PhotoponSignupViewController.m
//  Photopon
//
//  Created by Hayk Hayotsyan on 19/10/15.
//  Copyright © 2015 Photopon. All rights reserved.
//

#import "PhotoponSignupViewController.h"

@implementation PhotoponSignupViewController




- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.signUpView setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1]];
    [self.signUpView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photopon-logo.png"]]];
    
    //qself.signUpView.dismissButton.alpha = 0;
    
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    float x = (self.signUpView.bounds.size.width - 300.0f) / 2;
    [self.signUpView.logo setFrame:CGRectMake(x, 30, 300.0f, 100.0f)];
}



@end
