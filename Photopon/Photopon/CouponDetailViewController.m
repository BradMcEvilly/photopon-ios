//
//  CouponDetailViewController.m
//  Photopon
//
//  Created by Hayk Hayotsyan on 20/11/15.
//  Copyright © 2015 Photopon. All rights reserved.
//

#import "CouponDetailViewController.h"
#import "Helper.h"
#import <Parse/Parse.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "PhotoponCameraView.h"
#import "HeaderViewController.h"
#import "AlertBox.h"

@interface CouponDetailViewController ()
@end



@implementation CouponDetailViewController

NSInteger selectedCoupon = 0;

-(void)redeemCoupon {
    NSInteger thisCouponIndex = selectedCoupon;

    NSArray* allPFCoupons = GetNearbyCouponsPF();
    
    PFObject* coupon = [allPFCoupons objectAtIndex:thisCouponIndex];
    [coupon incrementKey:@"numRedeemed"];
    [coupon saveInBackground];
    
    
    [AlertBox showMessageFor:self withTitle:@"Your coupon"
                 withMessage:[NSString stringWithFormat:@"%@ %@", @"Your coupon code is: ", [coupon objectForKey:@"code"]]
                  leftButton:nil
                 rightButton:@"Awesome!"
                  leftAction:nil
                 rightAction:nil];
    
    SendGAEvent(@"user_action", @"coupon_details", @"coupon_redeemed");
    CreateRedeemedLog(NULL, coupon);
    
}

-(void)getCoupon {

    [AlertBox showMessageFor:self withTitle:@"Are you sure?"
                 withMessage:@"You can redeem coupon once. Are you sure you want to redeem it now?"
                  leftButton:@"Cancel"
                 rightButton:@"Redeem"
                  leftAction:nil
                 rightAction:@selector(redeemCoupon)];
    
}

-(void)giveCoupon {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Goto_AddPhotopon" object:nil userInfo:@{
                                                                                                         @"index": @(selectedCoupon)
                                                                                                         }];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    SendGAEvent(@"user_action", @"coupon_details", @"give_pressed");

    
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [HeaderViewController addBackHeaderToView:self withTitle:@"Coupon Details"];

    NSArray* allPFCoupons = GetNearbyCouponsPF();
    
    if ([allPFCoupons count] <= selectedCoupon) {
        [self dismissViewControllerAnimated:YES completion:NULL];

        return;
    }
    
    PFObject* coupon = [allPFCoupons objectAtIndex:selectedCoupon];
 
    
    PFObject* company = [coupon objectForKey:@"company"];
    PFFile* pic = [company objectForKey:@"image"];
    
    self.couponTitle.text = [coupon objectForKey:@"title"];
    self.couponDescription.text = [coupon objectForKey:@"description"];
    
    NSDate* exp = [coupon objectForKey:@"expiration"];
    NSDate* now = [NSDate date];
    
    int numDays = DaysBetween(now, exp);
    
    
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:@"MM/dd/yyyy"];
    self.couponExpiration.text = [NSString stringWithFormat:@"Expires %@", [dateFormater stringFromDate:exp]];
    if (numDays > 2) {
        [self.couponExpiration setTextColor:[UIColor colorWithRed:0 green:0.4 blue:0 alpha:1]];
    } else if (numDays > 1) {
        [self.couponExpiration setTextColor:[UIColor colorWithRed:0.6 green:0.3 blue:0 alpha:1]];
    } else {
        [self.couponExpiration setTextColor:[UIColor colorWithRed:0.4 green:0 blue:0 alpha:1]];
    }
    
    
    [self.couponImage sd_setImageWithURL:[NSURL URLWithString:pic.url] placeholderImage:[UIImage imageNamed:@"couponplaceholder.png"]];
    
    [self.getButton addTarget:self action:@selector(getCoupon) forControlEvents:UIControlEventTouchDown];
    
    [self.giveButton addTarget:self action:@selector(giveCoupon) forControlEvents:UIControlEventTouchDown];

}



-(void)viewWillAppear:(BOOL)animated {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"CouponDetailScreen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    SendGAEvent(@"user_action", @"coupon_details", @"opened");

}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setCouponIndex:(NSInteger)thisCouponIndex {
    selectedCoupon = thisCouponIndex;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
