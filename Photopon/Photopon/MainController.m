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
#import "AlertBox.h"
#import "ChatMessagesController.h"
#import "PhotoponViewController.h"
#import "UIColor+Convinience.h"

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
    
    BOOL hasUser;
}


-(void) updatePageTitle
{
    UIViewController *currentView = [self.viewControllers objectAtIndex:0];
    self.title = currentView.title;
}







-(void) gotoNotificationView {
    dispatch_async(dispatch_get_main_queue(), ^{
    [self setViewControllers:@[notificationsView]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:NO completion:nil];
    });
}

-(void) gotoFriendsView {
    dispatch_async(dispatch_get_main_queue(), ^{
    [self setViewControllers:@[friendsView]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:NO completion:nil];
    });
}

-(void) gotoCouponsView {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setViewControllers:@[couponsView]
                       direction:UIPageViewControllerNavigationDirectionForward
                        animated:NO completion:^(BOOL finished) {
                            NSLog(@"%d", finished);
                        }];
    });
}

-(void) gotoWalletView {
    dispatch_async(dispatch_get_main_queue(), ^{
    [self setViewControllers:@[walletView]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:NO completion:nil];
    });
}

-(void) gotoAddPhotoponView: (NSNotification*)notification {
    if (notification.userInfo) {
        if (notification.userInfo[@"index"]) {
            NSInteger index = [notification.userInfo[@"index"] integerValue];
            [photoponView setCurrentCouponIndex:index];
        }
        [photoponView setSelectedFriend: notification.userInfo[@"friendId"]];
        
    }

    dispatch_async(dispatch_get_main_queue(), ^{
    [self setViewControllers:@[photoponView]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:NO completion:nil];
    });
}

-(void) handleNotifications: (NSNotification*)notification {
    if (notification.userInfo) {
        NSString* notificationId = notification.userInfo[@"notificationId"];
        NSString* type = notification.userInfo[@"type"];
        
        PFQuery *query = [PFQuery queryWithClassName:@"Notifications"];
        [query getObjectInBackgroundWithId:notificationId block:^(PFObject *item, NSError *error) {
            
            if ([type isEqualToString:@"FRIEND"]) {
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"Goto_Notifications" object:nil userInfo:@{}];
                
            } else if ([type isEqualToString:@"MESSAGE"]) {
                PFUser* assocUser = [item objectForKey:@"assocUser"];
                //[assocUser fetchIfNeeded];
                
                ChatMessagesController* messageCtrl = (ChatMessagesController*)[self.storyboard instantiateViewControllerWithIdentifier:@"SBMessages"];
                [messageCtrl setUser:assocUser];
                
                [self presentViewController:messageCtrl animated:YES completion:nil];

                
            } else if ([type isEqualToString:@"PHOTOPON"]) {
                PFObject* assocPhotopon = [item objectForKey:@"assocPhotopon"];
            
                PhotoponViewController* photoponViewCtrl = (PhotoponViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"SBPhotoponView"];
                [photoponViewCtrl setPhotopon:assocPhotopon];
                
                [self presentViewController:photoponViewCtrl animated:YES completion:nil];
                    
            }
            
            [item deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            }];
            
        }];

        
        
    }
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    UpdateNearbyCoupons();

    self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;

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
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotifications:)
                                                 name:@"Handle_Notification"
                                               object:nil];
    

    
    
    PFUser* cUser = [PFUser currentUser];
    
    photoponView = [self.storyboard instantiateViewControllerWithIdentifier:@"SBPhotoponCam"];
    notificationsView = [self setupNotificationsViewController];
    friendsView = [self.storyboard instantiateViewControllerWithIdentifier:@"SBFriends"];
    walletView = [self.storyboard instantiateViewControllerWithIdentifier:@"SBWallet"];
//    couponsView = [self.storyboard instantiateViewControllerWithIdentifier:@"SBCoupons"];
    couponsView = [self setupCouponsViewController];

    hasUser = cUser != nil;
    
    if (cUser) {
        [photoponView setPageViewController:self];
    
        myViewControllers = @[photoponView, notificationsView,friendsView, couponsView, walletView];
        
        navController = [self.storyboard instantiateViewControllerWithIdentifier:@"MainCtrl"];
        
        [self setViewControllers:@[photoponView]
                       direction:UIPageViewControllerNavigationDirectionForward
                        animated:NO completion:nil];
    } else {
        
        myViewControllers = @[notificationsView, couponsView];
        
        navController = [self.storyboard instantiateViewControllerWithIdentifier:@"MainCtrl"];
        
        [self setViewControllers:@[notificationsView]
                       direction:UIPageViewControllerNavigationDirectionForward
                        animated:NO completion:nil];
        
    }
    
    [self updatePageTitle];
    
    
    [RealTimeNotificationHandler setupManager];
    
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIUserId value:[[PFUser currentUser] objectId]];
    
}

-(void)viewWillAppear:(BOOL)animated {
    PFUser* cUser = [PFUser currentUser];
    BOOL hasUserNew = cUser != nil;
    
    if (hasUserNew != hasUser) {
        hasUser = hasUserNew;
        [self viewDidLoad];
    }
    

}

-(void)viewDidAppear:(BOOL)animated {
    if (![CLLocationManager locationServicesEnabled]) {
        
        [AlertBox showAlertFor:self
                     withTitle:@"No permission"
                   withMessage:@"Location services must be enabled in order to use Photopon"
                    leftButton:nil
                   rightButton:@"OK"
                    leftAction:nil
                   rightAction:nil];
        
    } else {
        UpdateNearbyCoupons();
    }
    

}


-(UIViewController *)viewControllerAtIndex:(NSUInteger)index
{
    return myViewControllers[index];
}


-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController
     viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger currentIndex = [myViewControllers indexOfObject:viewController] + myViewControllers.count;
    [photoponView setSelectedFriend: nil];

    --currentIndex;
    
    currentIndex = currentIndex % (myViewControllers.count);
    UIViewController* ctrl = [myViewControllers objectAtIndex:currentIndex];
    SendGAEvent(@"user_action", @"main_slider", @"slide_left");

    return ctrl;
}
 
-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger currentIndex = [myViewControllers indexOfObject:viewController];
   [photoponView setSelectedFriend: nil];
    ++currentIndex;
    
    currentIndex = currentIndex % (myViewControllers.count);
    UIViewController* ctrl = [myViewControllers objectAtIndex:currentIndex];
    SendGAEvent(@"user_action", @"main_slider", @"slide_right");
    return ctrl;
}
 

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (completed) {
        [self updatePageTitle];
    }
}

#pragma mark - Controllers setup

- (UINavigationController *)setupCouponsViewController {
    UIViewController *couponVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SBCoupons"];
    UINavigationController *couponNavigationController = [[UINavigationController alloc]initWithRootViewController:couponVC];
    couponNavigationController.navigationBar.barTintColor = [UIColor colorWithHexString:@"#D94CCB" alpha:1.0];
    couponNavigationController.navigationBar.tintColor = [UIColor whiteColor];
    return couponNavigationController;
}

- (UINavigationController *)setupNotificationsViewController {
    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"NotificationController"];
    UINavigationController *nc = [[UINavigationController alloc]initWithRootViewController:vc];
    nc.navigationBar.barTintColor = [UIColor colorWithHexString:@"#F26161" alpha:1.0];
    nc.navigationBar.tintColor = [UIColor whiteColor];
    return nc;
}

@end
