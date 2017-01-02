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
    [self.signUpView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photopon-logo-black.png"]]];
    self.signUpView.dismissButton.alpha = 1;
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    
    float logoSize = self.signUpView.bounds.size.width - 60;
    
    float x = (self.signUpView.bounds.size.width - logoSize) / 2;
    
    
    [self.signUpView.logo setFrame:CGRectMake(x, 30, logoSize, logoSize / 3)]; // Logo picture is 3:1 proportion
    

}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"SignupScreen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}



@end
