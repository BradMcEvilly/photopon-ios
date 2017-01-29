//
//  CouponLocationsTableViewController.m
//  Photopon
//
//  Created by Ante Karin on 09/10/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import "CouponLocationsTableViewController.h"
#import "CouponBasicCell.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "CouponDetailsViewController.h"

@interface CouponLocationsTableViewController ()

@end

@implementation CouponLocationsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Locations";

    NSArray *couponLocations = [self.coupon objectForKey:@"locations"];
    if (couponLocations.count > 0) {
        [self retrieveLocationsObjectsWithIDs:couponLocations];
    } else {
        [self retrieveAllLocationsForOwnerID:[self.coupon objectForKey:@"owner"]];
    }

    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100;
}

-(void)setLocationObjects:(NSArray *)locationObjects {
    _locationObjects = locationObjects;
    [self.tableView reloadData];
}

- (void)retrieveLocationsObjectsWithIDs:(NSArray *)ids {
    NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"objectId IN %@", ids]                                                                                                                     ;
    PFQuery *query = [PFQuery queryWithClassName:@"Location" predicate:filterPredicate];

    CLLocation *location = GetCurrentLocation();
    PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLocation:location];
    [query whereKey:@"location" nearGeoPoint:geoPoint withinKilometers:400000];

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        self.locationObjects = objects;
    }];
}

- (void)retrieveAllLocationsForOwnerID:(PFObject* )owner {
    PFQuery *query = [PFQuery queryWithClassName:@"Location"];
    [query whereKey:@"location" nearGeoPoint:[PFGeoPoint geoPointWithLocation:GetCurrentLocation()]withinKilometers:40000];
    [query includeKey:@"owner"];
    [query whereKey:@"owner" equalTo:owner];

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        self.locationObjects = objects;
    }];
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.locationObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PFObject *locationObject = self.locationObjects[indexPath.row];
    CouponBasicCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CouponBasicCell"];

    cell.titleLabel.text = [locationObject objectForKey:@"name"];
    cell.addressLabel.text = [locationObject objectForKey:@"address"];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    CouponDetailsViewController *detailsVC = [[UIStoryboard storyboardWithName:@"CouponDetails" bundle:nil]instantiateViewControllerWithIdentifier:@"CouponDetailsViewController"];
    detailsVC.coupon = self.coupon;
    detailsVC.selectedCouponIndex = self.selectedCouponIndex;
    detailsVC.location = self.locationObjects[indexPath.row];
    [self.navigationController pushViewController:detailsVC animated:YES];
}

@end
