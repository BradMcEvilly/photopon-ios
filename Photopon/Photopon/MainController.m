//
//  MainController.m
//  Photopon
//
//  Created by Hayk Hayotsyan on 12/8/15.
//  Copyright (c) 2015 Photopon. All rights reserved.
//

#import "MainController.h"
#import "LogHelper.h"
#import <FontAwesome/NSString+FontAwesome.h>
#import "Parse/Parse.h"
#import "Helper.h"
#import "LeftMenuViewController.h"
#import "PhotoponCameraView.h"
#import "PhotoponCameraPlaceholderViewController.h"

@implementation MainController
{
    NSArray *myViewControllers;
    UINavigationController* navController;
    
    
    
    UIViewController *notificationsView;
    PhotoponCameraPlaceholderViewController *photoponView;
    UIViewController *friendsView;
    UIViewController *couponsView;
    UIViewController *walletView;
    
    CLLocationManager *locationManager;
}


-(void) updatePageTitle
{
    UIViewController *currentView = [self.viewControllers objectAtIndex:0];
    self.title = currentView.title;
}







-(IBAction)onLeftMenuClick:(id)sender
{
    LeftMenuViewController* leftMenu = (LeftMenuViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"SBLeftMenu"];

    leftMenu.providesPresentationContextTransitionStyle = YES;
    leftMenu.definesPresentationContext = YES;
    
    [leftMenu onClickHook:^(NSString *menuItem) {
        __weak typeof(self) weakSelf = self;

        
        if ([menuItem isEqualToString:@"notifications"]) {
            [self gotoNotificationView];

        }
        
        if ([menuItem isEqualToString:@"friends"]) {
            
            [self setViewControllers:@[friendsView]
                           direction:UIPageViewControllerNavigationDirectionForward
                            animated:NO completion:^(BOOL finished) {
                                __strong typeof(self) strongSelf = weakSelf;
                                [strongSelf updatePageTitle];
                            }];
        }
        
        if ([menuItem isEqualToString:@"coupons"]) {
            
            [self setViewControllers:@[couponsView]
                           direction:UIPageViewControllerNavigationDirectionForward
                            animated:NO completion:^(BOOL finished) {
                                __strong typeof(self) strongSelf = weakSelf;
                                [strongSelf updatePageTitle];
                            }];
        }
        
        if ([menuItem isEqualToString:@"wallet"]) {
            
            [self setViewControllers:@[walletView]
                           direction:UIPageViewControllerNavigationDirectionForward
                            animated:NO completion:^(BOOL finished) {
                                __strong typeof(self) strongSelf = weakSelf;
                                [strongSelf updatePageTitle];
                            }];
        }
        
        
        if ([menuItem isEqualToString:@"addphotopon"]) {
            PhotoponCameraView* camCtrl = (PhotoponCameraView*)[self.storyboard instantiateViewControllerWithIdentifier:@"SBPhotoponCam"];
            [camCtrl setPageViewController: nil];
            [self.navigationController presentViewController:camCtrl animated:true completion:nil];

        }
        
        
        
        
        if ([menuItem isEqualToString:@"settings"]) {
            UIViewController *settings = [self.storyboard instantiateViewControllerWithIdentifier:@"SBSettings"];
            [self.navigationController pushViewController:settings animated:true];
        }
        
        if ([menuItem isEqualToString:@"signout"]) {
            [PFUser logOut];
            UIViewController* loginCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginCtrl"];
            [self presentViewController:loginCtrl animated:true completion:nil];
        }
        
        
        
    }];
    
    
    
    [leftMenu setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    [self presentViewController:leftMenu animated:NO completion:nil];

}





-(void) gotoNotificationView {
    __weak typeof(self) weakSelf = self;

    [self setViewControllers:@[notificationsView]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:NO completion:^(BOOL finished) {
                        __strong typeof(self) strongSelf = weakSelf;
                        [strongSelf updatePageTitle];
                    }];
}


-(void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.delegate = self;
    self.dataSource = self;
    
    
    
    
    photoponView = [self.storyboard instantiateViewControllerWithIdentifier:@"SBPhotoponCamPlaceHolder"];
    notificationsView = [self.storyboard instantiateViewControllerWithIdentifier:@"SBNotifications"];
    friendsView = [self.storyboard instantiateViewControllerWithIdentifier:@"SBFriends"];
    couponsView = [self.storyboard instantiateViewControllerWithIdentifier:@"SBCoupons"];
    walletView = [self.storyboard instantiateViewControllerWithIdentifier:@"SBWallet"];
    
    [photoponView setPageViewController:self];
    
    myViewControllers = @[photoponView, notificationsView,friendsView,couponsView,walletView];
    
    navController = [self.storyboard instantiateViewControllerWithIdentifier:@"MainCtrl"];
    
    [self setViewControllers:@[notificationsView]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:NO completion:nil];
    
    [self updatePageTitle];
    
    
    
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:[NSString fontAwesomeIconStringForEnum:FABars] style:UIBarButtonItemStylePlain target:self action:@selector(onLeftMenuClick:)];
    
    
    UIFont* font = [UIFont fontWithName:kFontAwesomeFamilyName size:22.0];
    
    
    [leftButton setTitleTextAttributes:@{
         NSFontAttributeName: font
    } forState:UIControlStateNormal];
    
    self.navigationItem.leftBarButtonItem = leftButton;

    
    if (![CLLocationManager locationServicesEnabled]) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Photopon"
                                                        message:@"Location services must be enabled in order to use Photopon."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        
        [alert show];
    } else {
        UpdateNearbyCoupons();
    }
    
    [RealTimeNotificationHandler setupManager];
    
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIUserId value:[[PFUser currentUser] objectId]];
    
}




-(UIViewController *)viewControllerAtIndex:(NSUInteger)index
{
    return myViewControllers[index];
}


-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController
     viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger currentIndex = [myViewControllers indexOfObject:viewController] + myViewControllers.count;
    
    --currentIndex;
    
    currentIndex = currentIndex % (myViewControllers.count);
    UIViewController* ctrl = [myViewControllers objectAtIndex:currentIndex];
    return ctrl;
}
 
-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger currentIndex = [myViewControllers indexOfObject:viewController];
    
    ++currentIndex;
    
    currentIndex = currentIndex % (myViewControllers.count);
    UIViewController* ctrl = [myViewControllers objectAtIndex:currentIndex];
    return ctrl;
}
 

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (completed) {
        [self updatePageTitle];
    }
}




@end
