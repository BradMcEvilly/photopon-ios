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

@implementation MainController
{
    NSArray *myViewControllers;
    UINavigationController* navController;
    
    UIView* popupMenu;
    UIView* leftPopupMenu;
    
    
    UIViewController *notificationsView;
    UIViewController *photoponView;
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


-(void)hideRightMenu {
    if (popupMenu != NULL) {
        [popupMenu removeFromSuperview];
        popupMenu = NULL;
    }
}



-(void)hideLeftMenu {
    if (leftPopupMenu != NULL) {
        [leftPopupMenu removeFromSuperview];
        leftPopupMenu = NULL;
    }
}





-(void)showSettings {
    [self hideRightMenu];
    UIViewController *settings = [self.storyboard instantiateViewControllerWithIdentifier:@"SBSettings"];
    [self.navigationController pushViewController:settings animated:true];
}


-(void)logoutUser {
    [self hideRightMenu];
    
    [PFUser logOut];
    UIViewController* loginCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginCtrl"];
    [self presentViewController:loginCtrl animated:true completion:nil];
}


-(IBAction)onRightMenuClick:(id)sender
{
    if (popupMenu) {
        [self hideRightMenu];
        return;
    }

    int width = self.view.bounds.size.width;
    int height = self.view.bounds.size.height;
    
    int menuWidth = 160;
    int menuHeight = 80;
    
    popupMenu = [[UIView alloc] initWithFrame:CGRectMake(width - menuWidth - 3, 0, menuWidth, menuHeight)];
    popupMenu.backgroundColor = [UIColor whiteColor];

    popupMenu.layer.masksToBounds = NO;
    popupMenu.layer.shadowOffset = CGSizeMake(0, 0);
    popupMenu.layer.shadowRadius = 3;
    popupMenu.layer.shadowOpacity = 0.5;
    
    [self.view addSubview:popupMenu];
    
    // create Image View with image back (your blue cloud)
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, width, height)];
//    UIImage *image =  [UIImage imageNamed:[NSString stringWithFormat:@"myImage.png"]];
//    [imageView setImage:image];
//    [viewPopup addSubview:imageView];
    
    UIButton *buttonSettings = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, menuWidth, menuHeight / 2)];
    [buttonSettings setTitle:@"Settings" forState:UIControlStateNormal];
    [buttonSettings setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [buttonSettings addTarget:self action:@selector(showSettings) forControlEvents:UIControlEventTouchDown];
    [popupMenu addSubview:buttonSettings];
    
    
    
    UIButton *buttonLogout = [[UIButton alloc] initWithFrame:CGRectMake(0, menuHeight / 2, menuWidth, menuHeight / 2)];
    [buttonLogout setTitle:@"Logout" forState:UIControlStateNormal];
    [buttonLogout setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [buttonLogout addTarget:self action:@selector(logoutUser) forControlEvents:UIControlEventTouchDown];
    [popupMenu addSubview:buttonLogout];
    
    
    
}







-(void) showScrollPage:(id)sender {
    [self hideLeftMenu];
    NSInteger viewId = ((UIButton*)sender).tag;
    
    if (viewId < 4) {
        [self setViewControllers:@[myViewControllers[viewId+1]]
                       direction:UIPageViewControllerNavigationDirectionForward
                        animated:NO completion:nil];
    } else if (viewId == 4){ // Settings page
        UIViewController *settings = [self.storyboard instantiateViewControllerWithIdentifier:@"SBSettings"];
        [self.navigationController pushViewController:settings animated:true];
    }
    
    [self updatePageTitle];
}

-(UIButton*)createLeftMenuButton:(NSString*)pageName withId:(NSInteger)viewId withFrame:(CGRect)rect withIcon:(NSString*)icon{
    
    
    UIButton *button = [[UIButton alloc] initWithFrame:rect];
    [button setTitle:pageName forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(showScrollPage:) forControlEvents:UIControlEventTouchDown];
    [leftPopupMenu addSubview:button];
    
    
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.contentEdgeInsets = UIEdgeInsetsMake(0, rect.size.height, 0, 0);
    [button setTag:viewId];
    
    
    int shrinkFactor = 20;
    
    
    UIImageView* iconView = CreateFAImage(icon, rect.size.height - shrinkFactor);
    UIView* iconHolder = [[UIView alloc] initWithFrame:CGRectMake(rect.origin.x + shrinkFactor/2, rect.origin.y + shrinkFactor/2, rect.size.height - shrinkFactor, rect.size.height - shrinkFactor)];
    [iconHolder addSubview:iconView];
    [leftPopupMenu addSubview:iconHolder];
    return button;
}

-(IBAction)onLeftMenuClick:(id)sender
{
    if (leftPopupMenu) {
        [self hideLeftMenu];
        return;
    }
    
    int width = self.view.bounds.size.width;
    int height = self.view.bounds.size.height;
    
    int menuWidth = width * 0.8;
    int menuHeight = height;
    int menuItemHeight = 40;
    
    leftPopupMenu = [[UIView alloc] initWithFrame:CGRectMake(0, 0, menuWidth, menuHeight)];
    leftPopupMenu.backgroundColor = [UIColor whiteColor];
    
    leftPopupMenu.layer.masksToBounds = NO;
    leftPopupMenu.layer.shadowOffset = CGSizeMake(0, 0);
    leftPopupMenu.layer.shadowRadius = 3;
    leftPopupMenu.layer.shadowOpacity = 0.5;
    
    [self.view addSubview:leftPopupMenu];
    
    
    
    [self createLeftMenuButton:@"Notifications" withId:0 withFrame:CGRectMake(0, 0, menuWidth, menuItemHeight) withIcon:@"fa-info"];
    [self createLeftMenuButton:@"Friends" withId:1 withFrame:CGRectMake(0, menuItemHeight, menuWidth, menuItemHeight) withIcon:@"fa-users"];
    [self createLeftMenuButton:@"Coupons" withId:2 withFrame:CGRectMake(0, 2 * menuItemHeight, menuWidth, menuItemHeight) withIcon:@"fa-gift"];
    [self createLeftMenuButton:@"Wallet" withId:3 withFrame:CGRectMake(0, 3 * menuItemHeight, menuWidth, menuItemHeight) withIcon:@"fa-money"];
    [self createLeftMenuButton:@"Settings" withId:4 withFrame:CGRectMake(0, 4 * menuItemHeight, menuWidth, menuItemHeight) withIcon:@"fa-cog"];

}








-(void)viewDidLoad
{
    [super viewDidLoad];
    
    leftPopupMenu = NULL;
    
    self.delegate = self;
    self.dataSource = self;
    
    
    
    
    photoponView = [self.storyboard instantiateViewControllerWithIdentifier:@"SBPhotoponCam"];
    notificationsView = [self.storyboard instantiateViewControllerWithIdentifier:@"SBNotifications"];
    friendsView = [self.storyboard instantiateViewControllerWithIdentifier:@"SBFriends"];
    couponsView = [self.storyboard instantiateViewControllerWithIdentifier:@"SBCoupons"];
    walletView = [self.storyboard instantiateViewControllerWithIdentifier:@"SBWallet"];
    
    myViewControllers = @[photoponView, notificationsView,friendsView,couponsView,walletView];
    
    navController = [self.storyboard instantiateViewControllerWithIdentifier:@"MainCtrl"];
    
    [self setViewControllers:@[notificationsView]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:NO completion:nil];
    
    [self updatePageTitle];
    
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:[NSString fontAwesomeIconStringForEnum:FAEllipsisV] style:UIBarButtonItemStylePlain target:self action:@selector(onRightMenuClick:)];
    
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:[NSString fontAwesomeIconStringForEnum:FABars] style:UIBarButtonItemStylePlain target:self action:@selector(onLeftMenuClick:)];
    
    
    UIFont* font = [UIFont fontWithName:kFontAwesomeFamilyName size:22.0];
    
    [rightButton setTitleTextAttributes:@{
         NSFontAttributeName: font
    } forState:UIControlStateNormal];
    
    
    [leftButton setTitleTextAttributes:@{
         NSFontAttributeName: font
    } forState:UIControlStateNormal];
    
    self.navigationItem.rightBarButtonItem = rightButton;
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
    
    return [myViewControllers objectAtIndex:currentIndex];
}
 
-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger currentIndex = [myViewControllers indexOfObject:viewController];
    
    ++currentIndex;
    
    currentIndex = currentIndex % (myViewControllers.count);
    return [myViewControllers objectAtIndex:currentIndex];
}
 

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (completed) {
        [self updatePageTitle];
    }
}




@end
