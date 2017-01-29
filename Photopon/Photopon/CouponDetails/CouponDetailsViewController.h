//
//  CouponDetailsViewController.h
//  Photopon
//
//  Created by Ante Karin on 01/10/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CouponDetailsViewController : UIViewController

@property (nonatomic, strong) PFObject *coupon;
@property (nonatomic, strong) PFObject *location;
@property (nonatomic, assign) NSInteger selectedCouponIndex;

@end
