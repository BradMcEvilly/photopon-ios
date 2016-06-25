//
//  AppNavigationStackHelper.m
//
//  Created by Ante Karin on 05/05/16.
//

#import "AppNavigationStackHelper.h"

@implementation AppNavigationStackHelper

+ (void)dismissAllModalControllersFromTopModalController:(UIViewController *)topController {
    UIViewController *viewController = topController;

    while (viewController && viewController != [UIApplication sharedApplication].keyWindow.rootViewController) {
        if (viewController.presentingViewController) {
            viewController = viewController.presentingViewController;
        } else if (viewController.navigationController.presentingViewController) {
            viewController = viewController.navigationController.presentingViewController;
        }
    }

    [viewController dismissViewControllerAnimated:YES completion:nil];
}

+ (void)dismissAllModalControllersFromTopModalController:(UIViewController *)topController completion:(void (^) (void))completion {
    UIViewController *viewController = topController;

    while (viewController && viewController != [UIApplication sharedApplication].keyWindow.rootViewController) {
        if (viewController.presentingViewController) {
            viewController = viewController.presentingViewController;
        } else if (viewController.navigationController.presentingViewController) {
            viewController = viewController.navigationController.presentingViewController;
        }
    }

    [viewController dismissViewControllerAnimated:YES completion:completion];
}

+ (UIViewController*)topViewController {
    return [self topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

+ (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)rootViewController {
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController*)rootViewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    } else {
        return rootViewController;
    }
}

@end
