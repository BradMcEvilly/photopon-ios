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
#import "UIColor+Theme.h"
#import "NSDateFormatter+Common.h"

@interface CouponDetailViewController ()

@property (weak, nonatomic) IBOutlet UITextView *addressTextView;
@property (weak, nonatomic) IBOutlet UITextView *phoneTextView;

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

    [self setupCouponDetails];
}

-(void)viewWillAppear:(BOOL)animated {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"CouponDetailScreen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    SendGAEvent(@"user_action", @"coupon_details", @"opened");

}


#pragma mark - Setup

- (void)setupCouponDetails {
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

    [self.couponExpiration setTextColor:[UIColor labelExpiryColorForDate:exp]];

    NSDateFormatter *dateFormater = [NSDateFormatter defaultDateFormatter];
    self.couponExpiration.text = [NSString stringWithFormat:@"Expires %@", [dateFormater stringFromDate:exp]];

    [self.couponImage sd_setImageWithURL:[NSURL URLWithString:pic.url] placeholderImage:[UIImage imageNamed:@"couponplaceholder.png"]];

    [self.getButton addTarget:self action:@selector(getCoupon) forControlEvents:UIControlEventTouchDown];

    [self.giveButton addTarget:self action:@selector(giveCoupon) forControlEvents:UIControlEventTouchDown];

    NSArray *locations = [coupon objectForKey:@"locations"];
    if (locations.count > 0) {
        PFObject *location = locations.firstObject;
        self.addressTextView.text = location[@"address"];
        self.phoneTextView.text = location[@"phoneNumber"];
    }
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
