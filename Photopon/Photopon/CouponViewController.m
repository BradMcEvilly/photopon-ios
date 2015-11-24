//
//  CouponViewController.m
//  Photopon
//
//  Created by Hayk Hayotsyan on 21/8/15.
//  Copyright (c) 2015 Photopon. All rights reserved.
//

#import "CouponViewController.h"
#import "PhotoponDrawController.h"
#import "Parse/Parse.h"
#import "LogHelper.h"
#import "DBAccess.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "PhotoponCameraView.h"
#import "Helper.h"
#import "CouponTableViewCell.h"
#import "CouponDetailViewController.h"


@implementation CouponViewController
{
    NSArray* allCoupons;
    NSArray* allPFCoupons;
    int selectedCouponIndex;
    CLLocationManager* locationManager;
}




- (void) couponsUpdated {
    allCoupons = GetNearbyCoupons();
    allPFCoupons = GetNearbyCouponsPF();
    [self.couponTable reloadData];
}



-(void) getCoupon:(id)sender {
    UIButton* btn = (UIButton*)sender;
    NSInteger thisCouponIndex = btn.tag;
    
    UIAlertController* confirmationAlert = [UIAlertController alertControllerWithTitle:@"Are you sure?"
                                                                               message:@"You can redeem coupon once. Are you sure you want to redeem it now?"
                                                                        preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* getAction = [UIAlertAction actionWithTitle:@"Redeem" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
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

-(void) giveCoupon: (id)sender {
    UIButton* btn = (UIButton*)sender;
    NSInteger thisCouponIndex = btn.tag;
    
    PhotoponCameraView* camView = (PhotoponCameraView*)[self.storyboard instantiateViewControllerWithIdentifier:@"SBPhotoponCam"];
    [camView setCurrentCouponIndex:thisCouponIndex];
    [self showViewController:camView sender:nil];

}


-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.couponTable setDelegate:self];
    [self.couponTable setDataSource:self];
    
    allCoupons = GetNearbyCoupons();
    allPFCoupons = GetNearbyCouponsPF();
    [self.couponTable reloadData];

    NSLog(@"Registering listener for coupon update");
    AddCouponUpdateListener(self);
}

-(void) dealloc {
    RemoveCouponUpdateListener(self);
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [allCoupons count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CouponTableViewCell *cell = (CouponTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"CouponTableCell"];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CouponTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    NSDictionary *item = (NSDictionary *)[allCoupons objectAtIndex:indexPath.row];
    
    cell.title.text = [item objectForKey:@"title"];
    cell.longDescription.text = [item objectForKey:@"desc"];
    [cell.thumbImage sd_setImageWithURL:[NSURL URLWithString:[item objectForKey:@"pic"]] placeholderImage:[UIImage imageNamed:@"couponplaceholder.png"]];
    
    cell.getButton.tag = indexPath.row;
    [cell.getButton addTarget:self action:@selector(getCoupon:) forControlEvents:UIControlEventTouchDown];
    
    cell.giveButton.tag = indexPath.row;
    [cell.giveButton addTarget:self action:@selector(giveCoupon:) forControlEvents:UIControlEventTouchDown];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 110;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger thisCouponIndex = (int)indexPath.row;
    
    
    
    CouponDetailViewController* detailView = (CouponDetailViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"SBCouponDetails"];
    [detailView setCouponIndex:thisCouponIndex];
    [self showViewController:detailView sender:nil];
    
    
    
    
    
    /*
    PhotoponCameraView* camView = (PhotoponCameraView*)[self.storyboard instantiateViewControllerWithIdentifier:@"SBPhotoponCam"];

    [camView setCoupons:allCoupons withObjects:allPFCoupons];
    [camView setCurrentCouponIndex:indexPath.row];
    [self showViewController:camView sender:nil];
 */
}


@end
