//
//  CouponDetailViewController.h
//  Photopon
//
//  Created by Hayk Hayotsyan on 20/11/15.
//  Copyright © 2015 Photopon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CouponDetailViewController : UIViewController

-(void)setCouponIndex:(NSInteger)thisCouponIndex;

@property (weak, nonatomic) IBOutlet UIImageView *couponImage;
@property (weak, nonatomic) IBOutlet UILabel *couponTitle;
@property (weak, nonatomic) IBOutlet UILabel *couponDescription;

@property (weak, nonatomic) IBOutlet UIButton *giveButton;
@property (weak, nonatomic) IBOutlet UIButton *getButton;

@end
