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

@interface OnboardingViewController() <UIScrollViewDelegate, LocationServicesViewControllerDelegate, PushNotificationsDelegate, EnjoyPhotoponDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backgroundImageLeftConstraint;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;


@end

@implementation OnboardingViewController

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat xOffset = scrollView.contentOffset.x;
    self.backgroundImageLeftConstraint.constant = - xOffset / 7;
    [self.pageControl setCurrentPage:xOffset / [UIApplication sharedApplication].keyWindow.bounds.size.width];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"LocationServices"]) {
        LocationServicesViewController *vc = segue.destinationViewController;
        vc.delegate = self;
    } else if ([segue.identifier isEqualToString:@"PushNotifications"]) {
        PushNotificationsViewController *vc = segue.destinationViewController;
        vc.delegate = self;
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
    [self.navigationController presentViewController:vc animated:YES completion:nil];
}

@end
