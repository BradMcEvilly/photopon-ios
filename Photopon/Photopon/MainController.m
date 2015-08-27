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

@implementation MainController
{
    NSArray *myViewControllers;
    UINavigationController* navController;
    UIView* popupMenu;
}


-(void) updatePageTitle
{
    UIViewController *currentView = [self.viewControllers objectAtIndex:0];
    self.title = currentView.title;
}


-(void)hideMenu {
    if (popupMenu != NULL) {
        [popupMenu removeFromSuperview];
        popupMenu = NULL;
    }
}

-(void)showSettings {
    [self hideMenu];
    UIViewController *settings = [self.storyboard instantiateViewControllerWithIdentifier:@"SBSettings"];
    [self.navigationController pushViewController:settings animated:true];
}


-(void)logoutUser {
    [self hideMenu];
    
    [PFUser logOut];
    UIViewController* loginCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginCtrl"];
    [self presentViewController:loginCtrl animated:true completion:nil];
}


-(IBAction)onRightMenuClick:(id)sender
{
    [self hideMenu];

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

-(IBAction)onLeftMenuClick:(id)sender
{
    LogDebug(@"On left menu click");
}




-(void)viewDidLoad
{
    [super viewDidLoad];
    
    popupMenu = NULL;
    
    self.delegate = self;
    self.dataSource = self;
    
    UIViewController *p1 = [self.storyboard
                            instantiateViewControllerWithIdentifier:@"SBNotifications"];
    UIViewController *p2 = [self.storyboard
                            instantiateViewControllerWithIdentifier:@"SBFriendsMan"];
    UIViewController *p3 = [self.storyboard
                            instantiateViewControllerWithIdentifier:@"SBCoupons"];
    UIViewController *p4 = [self.storyboard
                            instantiateViewControllerWithIdentifier:@"SBWallet"];
    
    myViewControllers = @[p1,p2,p3,p4];
    
    navController = [self.storyboard instantiateViewControllerWithIdentifier:@"MainCtrl"];
    
    [self setViewControllers:@[p1]
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

}

-(UIViewController *)viewControllerAtIndex:(NSUInteger)index
{
    return myViewControllers[index];
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController
     viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger currentIndex = [myViewControllers indexOfObject:viewController];
    
    
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


/*
-(NSInteger)presentationCountForPageViewController:
(UIPageViewController *)pageViewController
{
    return myViewControllers.count;
}

-(NSInteger)presentationIndexForPageViewController:
(UIPageViewController *)pageViewController
{
    return 0;
}
*/
@end
