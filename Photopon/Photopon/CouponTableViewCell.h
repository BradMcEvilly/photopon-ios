//
//  CouponTableViewCell.h
//  Photopon
//
//  Created by Hayk Hayotsyan on 19/11/15.
//  Copyright © 2015 Photopon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface CouponTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *thumbImage;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *longDescription;
@property (weak, nonatomic) IBOutlet UILabel *expiration;

@property (weak, nonatomic) IBOutlet UIButton *getButton;
@property (weak, nonatomic) IBOutlet UIButton *giveButton;
@property (weak, nonatomic) IBOutlet UIImageView *verticalDividerView;

@property (nonatomic, strong) PFObject *coupon;

@end
