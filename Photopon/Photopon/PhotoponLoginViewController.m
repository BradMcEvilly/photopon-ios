//
//  PhotoponLoginViewController.m
//  Photopon
//
//  Created by Hayk Hayotsyan on 19/10/15.
//  Copyright © 2015 Photopon. All rights reserved.
//

#import "PhotoponLoginViewController.h"

@implementation PhotoponLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.logInView setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1]];
    [self.logInView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photopon-logo.png"]]];
    
    self.logInView.dismissButton.alpha = 0;
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    float x = (self.logInView.bounds.size.width - 300.0f) / 2;
    [self.logInView.logo setFrame:CGRectMake(x, 100, 300.0f, 100.0f)];
}

@end
