//
//  AppNavigationStackHelper.h
//
//  Created by Ante Karin on 05/05/16.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AppNavigationStackHelper : NSObject

+ (void)dismissAllModalControllersFromTopModalController:(UIViewController *)topController;
+ (void)dismissAllModalControllersFromTopModalController:(UIViewController *)topController completion:(void (^) (void))completion;

+ (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)rootViewController;
+ (UIViewController*)topViewController;

@end
