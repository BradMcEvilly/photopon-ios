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
#import "CouponWrapper.h"
#import "CouponLocationsViewController.h"
#import "GoogleMapsManager.h"

@interface CouponDetailViewController ()

@property (weak, nonatomic) IBOutlet UITextView *addressTextView;
@property (weak, nonatomic) IBOutlet UITextView *phoneTextView;
@property (weak, nonatomic) IBOutlet UIButton *locationsListButton;
@property (weak, nonatomic) IBOutlet UIView *locationsContainer;

@property (nonatomic, strong) PFObject *coupon;
@property (weak, nonatomic) IBOutlet UIButton *directionsButton;

@end

@implementation CouponDetailViewController

NSInteger selectedCoupon = 0;

-(void)redeemCoupon {
   if (!HasPhoneNumber(@"Please add and verify your mobile phone number to get this coupon.")) {
      return;
   }

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


-(void)shareThisCoupon {
    
}

-(void)getCoupon {
   if (!HasPhoneNumber(@"Please add and verify your mobile phone number to get this coupon.")) {
      return;
   }

    NSInteger thisCouponIndex = selectedCoupon;
    NSArray* allPFCoupons = GetNearbyCouponsPF();
    PFObject* coupon = [allPFCoupons objectAtIndex:thisCouponIndex];
    
    CouponWrapper* wrapper = [CouponWrapper fromObject:coupon];
    [wrapper getCoupon];
}

-(void)giveCoupon {
   if (!HasPhoneNumber(@"Please add and verify your mobile phone number to get this coupon.")) {
      return;
   }

   
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Goto_AddPhotopon" object:nil userInfo:@{
                                                                                                         @"index": @(selectedCoupon)
                                                                                                         }];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    SendGAEvent(@"user_action", @"coupon_details", @"give_pressed");
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupCouponDetails];

#ifdef DEBUG
    self.addressTextView.text = @"Portland university";
#endif
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

    self.coupon = coupon;

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
    if (locations.count == 1) {
        NSNumber *locationID = locations.firstObject;

        PFQuery *query = [PFQuery queryWithClassName:@"Location" predicate:[NSPredicate predicateWithFormat:@"objectId == %@", locationID]];
        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            PFObject *location = objects.firstObject;
            if (location) {
                self.addressTextView.text = location[@"address"];
                self.phoneTextView.text = location[@"phoneNumber"];
            }
        }];

        self.locationsListButton.hidden = YES;
        self.locationsContainer.hidden = NO;
        self.directionsButton.hidden = NO;
    } else {
        
        self.locationsContainer.hidden = YES;
        self.locationsListButton.hidden = NO;
        self.directionsButton.hidden = YES;
    }
}

-(void)setCouponIndex:(NSInteger)thisCouponIndex {
    selectedCoupon = thisCouponIndex;
}

#pragma mark - Handlers

- (IBAction)directionsButtonHandler:(id)sender {
    [GoogleMapsManager performNavigateToAddress:self.addressTextView.text];
}

- (IBAction)locationListButtonHandler:(id)sender {
    
    
    
    CouponLocationsViewController *vc = [[UIStoryboard storyboardWithName:@"CouponDetails" bundle:nil]instantiateViewControllerWithIdentifier:@"CouponLocationsViewController"];
    vc.coupon = self.coupon;
    //[self.navigationController pushViewController:vc animated:true];
    [self presentViewController:vc animated:true completion:nil];
    
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
