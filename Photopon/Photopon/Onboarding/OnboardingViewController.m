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

@interface OnboardingViewController() <UIScrollViewDelegate, LocationServicesViewControllerDelegate, PushNotificationsDelegate, EnjoyPhotoponDelegate, NumberVerificationDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backgroundImageLeftConstraint;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@property (nonatomic, weak) LocationServicesViewController *locationServicesVC;
@property (nonatomic, weak) PushNotificationsViewController *pushServicesVC;

@property (nonatomic, assign) BOOL didViewAlreadyAppear;

@end

@implementation OnboardingViewController

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];

    if (!self.didViewAlreadyAppear) {
        self.didViewAlreadyAppear = YES;
        if ([[UIApplication sharedApplication] isRegisteredForRemoteNotifications] && [CLLocationManager locationServicesEnabled]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.scrollView setContentOffset:CGPointMake([UIApplication sharedApplication].keyWindow.bounds.size.width * 3, 0) animated:YES];
            });
        }
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat xOffset = scrollView.contentOffset.x;
    self.backgroundImageLeftConstraint.constant = - xOffset / 7;
    [self.pageControl setCurrentPage:xOffset / [UIApplication sharedApplication].keyWindow.bounds.size.width];

    if (self.pageControl.currentPage == 2) {
        [self.pushServicesVC enablePushNotification];
    } else if (self.pageControl.currentPage == 3) {
        [self.locationServicesVC askForLocationServices];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"LocationServices"]) {
        LocationServicesViewController *vc = segue.destinationViewController;
        vc.delegate = self;
        self.locationServicesVC = vc;
    } else if ([segue.identifier isEqualToString:@"PushNotifications"]) {
        PushNotificationsViewController *vc = segue.destinationViewController;
        vc.delegate = self;
        self.pushServicesVC = vc;
    } else if ([segue.identifier isEqualToString:@"EnjoyPhotopon"]) {
        EnjoyPhotoponViewController *vc = segue.destinationViewController;
        vc.delegate = self;
    }
}

#pragma mark - LocationServicesViewControllerDelegate 

- (void)didAllowLocationServices {
    CGPoint newContentOffset = CGPointMake([UIApplication sharedApplication].keyWindow.bounds.size.width * 3, 0);
    [self.scrollView setContentOffset:newContentOffset animated:YES];
}

#pragma mark - PushNotificationsDelegate

- (void)userDidAllowPushNotifications {
    CGPoint newContentOffset = CGPointMake([UIApplication sharedApplication].keyWindow.bounds.size.width * 2, 0);
    [self.scrollView setContentOffset:newContentOffset animated:YES];
}

#pragma mark - EnjoyPhotoponDelegate

- (void)userShouldRegister {
    NumberVerificationViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"SBNumberVerification"];
   
    [vc setDelegate: self];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    [self.navigationController presentViewController:vc animated:YES completion:nil];
}

- (void)userShouldSkip {
    UIViewController *mainVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"MainCtrl"];
    mainVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    [self.navigationController presentViewController:mainVC animated:YES completion:nil];
}

#pragma mark - Number verification delegate

-(void)userVerifiedPhoneNumber {
    UIViewController *mainVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"MainCtrl"];
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    PFUser* currentUser = [PFUser currentUser];

    NSString* channel = [NSString stringWithFormat:@"User_%@", currentUser.objectId];
    [currentInstallation addUniqueObject:channel forKey:@"channels"];
    [currentInstallation saveInBackground];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    mainVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
   [self dismissViewControllerAnimated:NO completion:nil];
    [self.navigationController presentViewController:mainVC animated:YES completion:nil];
}

- (void)userSkippedVerification {
    [self userShouldSkip];
}

@end
