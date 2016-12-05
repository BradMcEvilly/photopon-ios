//
//  PhotoponUnavailableViewController.m
//  Photopon
//
//  Created by Ante Karin on 14/07/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import "PhotoponUnavailableViewController.h"
#import "UIView+CommonLayout.h"
#import <PFUser.h>

@interface PhotoponUnavailableViewController()

@property (weak, nonatomic) IBOutlet UIButton *chatButton;
@property (weak, nonatomic) IBOutlet UILabel *bodyLabel;

@end

@implementation PhotoponUnavailableViewController

- (IBAction)chatWithFriendsHandler:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Goto_Friends" object:nil];
}

+ (void)addToViewController:(UIViewController *)viewController forView:(UIView *)view {
    PhotoponUnavailableViewController *vc = [[self alloc]init];
    if (![PFUser currentUser]) {
        vc.chatButton.hidden = YES;
        vc.bodyLabel.text = @"We're working hard to bring Photopon private coupons and gifts to your local area.";
    }
    [view addSubviewAndFill:vc.view];
    [viewController addChildViewController:vc];
}

@end
