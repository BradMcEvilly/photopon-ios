//
//  PhotoponUnavailableViewController.m
//  Photopon
//
//  Created by Ante Karin on 14/07/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import "PhotoponUnavailableViewController.h"
#import "UIView+CommonLayout.h"

@interface PhotoponUnavailableViewController()



@end

@implementation PhotoponUnavailableViewController

- (IBAction)chatWithFriendsHandler:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Goto_Friends" object:nil];
}

+ (void)addToViewController:(UIViewController *)viewController forView:(UIView *)view {
    PhotoponUnavailableViewController *vc = [[self alloc]init];
    [view addSubviewAndFill:vc.view];
    [viewController addChildViewController:vc];
}

@end
