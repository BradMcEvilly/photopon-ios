//
//  CouponViewController.h
//  Photopon
//
//  Created by Hayk Hayotsyan on 21/8/15.
//  Copyright (c) 2015 Photopon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CouponViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *couponTable;

@end
