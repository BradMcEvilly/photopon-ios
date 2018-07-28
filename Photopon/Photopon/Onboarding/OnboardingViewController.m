//
//  OnboardingViewController.m
//  Photopon
//
//  Created by Ante Karin on 10/09/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import "OnboardingViewController.h"
#import "LocationServicesViewController.h"
#import "PushNotificationsViewController.h"
#import "EnjoyPhotoponViewController.h"
#import "NumberVerificationViewController.h"

@interface OnboardingViewController()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backgroundImageLeftConstraint;


@property (nonatomic, weak) LocationServicesViewController *locationServicesVC;
@property (nonatomic, weak) PushNotificationsViewController *pushServicesVC;

@property (nonatomic, assign) BOOL didViewAlreadyAppear;

@end

@implementation OnboardingViewController

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];

    
}








@end
