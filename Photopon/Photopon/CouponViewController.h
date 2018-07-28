//
//  CouponViewController.h
//  Photopon
//
//  Created by Hayk Hayotsyan on 21/8/15.
//  Copyright (c) 2015 Photopon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Helper.h"
@import CoreLocation;

@interface CouponViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, CouponUpdateDelegate>

@property (weak, nonatomic) IBOutlet UITableView *couponTable;
@property (weak, nonatomic) IBOutlet UIView *emptyView;

@end
