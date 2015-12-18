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


@interface CouponDetailViewController ()
@end



@implementation CouponDetailViewController

NSInteger selectedCoupon = 0;

-(void)getCoupon {

    NSInteger thisCouponIndex = selectedCoupon;
    
    UIAlertController* confirmationAlert = [UIAlertController alertControllerWithTitle:@"Are you sure?"
                                                                               message:@"You can redeem coupon once. Are you sure you want to redeem it now?"
                                                                        preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* getAction = [UIAlertAction actionWithTitle:@"Redeem" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        
        NSArray* allPFCoupons = GetNearbyCouponsPF();
        
        PFObject* coupon = [allPFCoupons objectAtIndex:thisCouponIndex];
        [coupon incrementKey:@"numRedeemed"];
        [coupon saveInBackground];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Your coupon"
                                                        message:[NSString stringWithFormat:@"%@ %@", @"Your coupon code is: ", [coupon objectForKey:@"code"]]
                                                       delegate:nil
                                              cancelButtonTitle:@"Awesome!"
                                              otherButtonTitles:nil];
        [alert show];
    }];
    
    
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
    
    [confirmationAlert addAction:getAction];
    [confirmationAlert addAction:cancelAction];
    [self presentViewController:confirmationAlert animated:YES completion:nil];
}

-(void)giveCoupon {
    
    PhotoponCameraView* camView = (PhotoponCameraView*)[self.storyboard instantiateViewControllerWithIdentifier:@"SBPhotoponCam"];
    [camView setCurrentCouponIndex:selectedCoupon];
    [self showViewController:camView sender:nil];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];

    
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
    [self.couponImage sd_setImageWithURL:[NSURL URLWithString:pic.url] placeholderImage:[UIImage imageNamed:@"couponplaceholder.png"]];
    
    [self.getButton addTarget:self action:@selector(getCoupon) forControlEvents:UIControlEventTouchDown];
    
    [self.giveButton addTarget:self action:@selector(giveCoupon) forControlEvents:UIControlEventTouchDown];

}



-(void)viewWillAppear:(BOOL)animated {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"CouponDetailScreen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
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
