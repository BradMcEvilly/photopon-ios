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
    PhotoponCameraView *photoponView;
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







-(void) gotoNotificationView {
    [self setViewControllers:@[notificationsView]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:NO completion:nil];
}

-(void) gotoFriendsView {
    [self setViewControllers:@[friendsView]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:NO completion:nil];
}

-(void) gotoCouponsView {
    [self setViewControllers:@[couponsView]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:NO completion:nil];
}

-(void) gotoWalletView {
    [self setViewControllers:@[walletView]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:NO completion:nil];
}

-(void) gotoAddPhotoponView: (NSNotification*)notification {
    if (notification.userInfo) {
        NSInteger index = [notification.userInfo[@"index"] integerValue];
        [photoponView setCurrentCouponIndex:index];
    }

    [self setViewControllers:@[photoponView]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:NO completion:nil];
}


-(void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.delegate = self;
    self.dataSource = self;
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gotoNotificationView)
                                                 name:@"Goto_Notifications"
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gotoFriendsView)
                                                 name:@"Goto_Friends"
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gotoCouponsView)
                                                 name:@"Goto_Coupons"
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gotoWalletView)
                                                 name:@"Goto_Wallet"
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gotoAddPhotoponView:)
                                                 name:@"Goto_AddPhotopon"
                                               object:nil];
    
    

    
    
    
    
    photoponView = [self.storyboard instantiateViewControllerWithIdentifier:@"SBPhotoponCam"];
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
    
    
    
    
//    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:[NSString fontAwesomeIconStringForEnum:FABars] style:UIBarButtonItemStylePlain target:self action:@selector(onLeftMenuClick:)];
    
    
//    UIFont* font = [UIFont fontWithName:kFontAwesomeFamilyName size:22.0];
    
    
//    [leftButton setTitleTextAttributes:@{
//         NSFontAttributeName: font
//    } forState:UIControlStateNormal];
    
//    self.navigationItem.leftBarButtonItem = leftButton;

    
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
