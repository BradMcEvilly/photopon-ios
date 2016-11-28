//
//  LocationServicesViewController.h
//  Photopon
//
//  Created by Ante Karin on 11/09/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LocationServicesViewControllerDelegate <NSObject>

- (void)didAllowLocationServices;

@end

@interface LocationServicesViewController : UIViewController

@property (nonatomic, weak) id<LocationServicesViewControllerDelegate> delegate;
- (void)askForLocationServices;

@end
