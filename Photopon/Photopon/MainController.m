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
}


-(void) updatePageTitle
{
    UIViewController *currentView = [self.viewControllers objectAtIndex:0];
    self.title = currentView.title;
}


-(IBAction)onRightMenuClick:(id)sender
{
    [PFUser logOut];
    
    UIViewController* loginCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginCtrl"];
    [self presentViewController:loginCtrl animated:true completion:nil];
    
}

-(IBAction)onLeftMenuClick:(id)sender
{
    LogDebug(@"On left menu click");
}




-(void)viewDidLoad
{
    [super viewDidLoad];
    
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
