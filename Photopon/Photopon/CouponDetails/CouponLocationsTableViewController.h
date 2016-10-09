//
//  CouponLocationsTableViewController.h
//  Photopon
//
//  Created by Ante Karin on 09/10/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface CouponLocationsTableViewController : UITableViewController

@property (nonatomic, strong) PFObject *coupon;
@property (nonatomic, strong) NSArray *locationObjects;
@property (nonatomic, assign) NSInteger selectedCouponIndex;

@end
