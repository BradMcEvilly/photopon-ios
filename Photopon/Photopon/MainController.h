//
//  MainController.h
//  Photopon
//
//  Created by Hayk Hayotsyan on 12/8/15.
//  Copyright (c) 2015 Photopon. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CoreLocation;

@interface MainController : UIPageViewController<UIPageViewControllerDelegate, UIPageViewControllerDataSource>

-(void) showScrollPage:(id)sender;
-(void) updatePageTitle;
-(void) gotoNotificationView;
@end
