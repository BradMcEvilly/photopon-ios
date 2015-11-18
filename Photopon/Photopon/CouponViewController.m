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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MyIdentifier"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSDictionary *item = (NSDictionary *)[allCoupons objectAtIndex:indexPath.row];
    cell.textLabel.text = [item objectForKey:@"title"];
    cell.detailTextLabel.text = [item objectForKey:@"desc"];
    
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:[item objectForKey:@"pic"]] placeholderImage:[UIImage imageNamed:@"couponplaceholder.png"]];

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedCouponIndex = (int)indexPath.row;
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Choose action"
                                                                   message:@"Do you want to Give or Get coupon?"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* giveAction = [UIAlertAction actionWithTitle:@"Give" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        
        PhotoponCameraView* camView = (PhotoponCameraView*)[self.storyboard instantiateViewControllerWithIdentifier:@"SBPhotoponCam"];
        [camView setCurrentCouponIndex:selectedCouponIndex];
        [self showViewController:camView sender:nil];
    }];
    
    
    UIAlertAction* getAction = [UIAlertAction actionWithTitle:@"Get" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        
        
        UIAlertController* confirmationAlert = [UIAlertController alertControllerWithTitle:@"Are you sure?"
                                                                       message:@"You can redeem coupon once. Are you sure you want to redeem it now?"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* getAction = [UIAlertAction actionWithTitle:@"Redeem" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            PFObject* coupon = [allPFCoupons objectAtIndex:selectedCouponIndex];
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
        
    }];
    
    
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
    
    [alert addAction:giveAction];
    [alert addAction:getAction];
    [alert addAction:cancelAction];
    
    
    
    [self presentViewController:alert animated:YES completion:nil];
    
    
    
    
    /*
    PhotoponCameraView* camView = (PhotoponCameraView*)[self.storyboard instantiateViewControllerWithIdentifier:@"SBPhotoponCam"];

    [camView setCoupons:allCoupons withObjects:allPFCoupons];
    [camView setCurrentCouponIndex:indexPath.row];
    [self showViewController:camView sender:nil];
 */
}


@end
