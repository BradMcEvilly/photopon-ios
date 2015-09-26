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


@implementation CouponViewController
{
    NSMutableArray* allCoupons;
    NSMutableArray* allPFCoupons;
    int selectedCouponIndex;
    CLLocationManager* locationManager;
}



- (void)getCouponsForLocation:(CLLocation*)location {
    
    NSLog(@"%f, %f", location.coordinate.latitude, location.coordinate.longitude);
    
    GetCouponsByLocation(location.coordinate.latitude, location.coordinate.longitude, ^(NSArray *results, NSError *error) {
        [allCoupons removeAllObjects];
        [allPFCoupons removeAllObjects];
        
        for (PFObject* object in results) {
            
            NSString* title = [object objectForKey:@"title"];
            NSString* desc = [object objectForKey:@"description"];
            PFObject* company = [object objectForKey:@"company"];
            //[company fetchIfNeeded];
            PFFile* pic = [company objectForKey:@"image"];
            
            [allCoupons addObject:@{
                                    @"title": title,
                                    @"desc": desc,
                                    @"pic": pic.url
                                    }];
            
            
            [allPFCoupons addObject:object];
        }
        [self.couponTable reloadData];
    });
    
    /*
    GetCoupons(^(NSArray *results, NSError *error) {
        [allCoupons removeAllObjects];
        [allPFCoupons removeAllObjects];
        
        for (PFObject* object in results) {
            
            NSString* title = [object objectForKey:@"title"];
            NSString* desc = [object objectForKey:@"description"];
            PFObject* company = [object objectForKey:@"company"];
            //[company fetchIfNeeded];
            PFFile* pic = [company objectForKey:@"image"];
            
            [allCoupons addObject:@{
                                    @"title": title,
                                    @"desc": desc,
                                    @"pic": pic.url
                                    }];
            
            
            [allPFCoupons addObject:object];
        }
        [self.couponTable reloadData];
    });
     */
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [self getCouponsForLocation:[locations lastObject]];
}





-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.couponTable setDelegate:self];
    [self.couponTable setDataSource:self];
    allCoupons = [NSMutableArray array];
    allPFCoupons = [NSMutableArray array];
    
    
    
    if ([CLLocationManager locationServicesEnabled]) {
       
        if (locationManager == nil) {
            locationManager = [[CLLocationManager alloc] init];
            locationManager.delegate = self;
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
            
            // Set a movement threshold for new events.
            locationManager.distanceFilter = 100; // meters
            
            CLAuthorizationStatus st = [CLLocationManager authorizationStatus];
            
            if (st == kCLAuthorizationStatusRestricted || st == kCLAuthorizationStatusDenied) {
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Photopon"
                                                                message:@"Location services must be enabled in order to use Photopon."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                
                [alert show];
                
                return;
            }
            
            if (st == kCLAuthorizationStatusNotDetermined) {
                [locationManager requestAlwaysAuthorization];
            } else {
                [self getCouponsForLocation: locationManager.location];
            }
            
            
            [locationManager startUpdatingLocation];
            
        }
    }


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
        [camView setCoupons:allCoupons withObjects:allPFCoupons];
        [camView setCurrentCouponIndex:selectedCouponIndex];
        [self showViewController:camView sender:nil];
    }];
    
    
    UIAlertAction* getAction = [UIAlertAction actionWithTitle:@"Get" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
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
    
    
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        
    }];
    
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
