//
//  CouponLocationsViewController.m
//  Photopon
//
//  Created by Ante Karin on 21/07/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import "CouponLocationsViewController.h"
#import "Helper.h"
#import "LocationCell.h"
#import "HeaderViewController.h"
#import "GoogleMapsManager.h"
#import "AlertBox.h"

@interface CouponLocationsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *locationObjects;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, assign) NSInteger selectedRow;

@end

@implementation CouponLocationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.selectedRow = -1;

    [HeaderViewController addBackHeaderToView:self withTitle:@"Locations"];

    NSArray *couponLocations = [self.coupon objectForKey:@"locations"];
    if (couponLocations.count > 0) {
        [self retrieveLocationsObjectsWithIDs:couponLocations];
    } else {
        [self retrieveAllLocationsForOwnerID:[self.coupon objectForKey:@"owner"]];
    }

    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 60;
}

- (void)retrieveLocationsObjectsWithIDs:(NSArray *)ids {
    NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"objectId IN %@", ids]                                                                                                                     ;
    PFQuery *query = [PFQuery queryWithClassName:@"Location" predicate:filterPredicate];

    CLLocation *location = GetCurrentLocation();
    PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLocation:location];
    [query whereKey:@"location" nearGeoPoint:geoPoint withinKilometers:400000];

    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        self.locationObjects = objects;
        [self.tableView reloadData];
    }];
}

- (void)retrieveAllLocationsForOwnerID:(PFObject* )owner {
    PFQuery *query = [PFQuery queryWithClassName:@"Location"];
    [query whereKey:@"location" nearGeoPoint:[PFGeoPoint geoPointWithLocation:GetCurrentLocation()]withinKilometers:40000];
    [query includeKey:@"owner"];
    [query whereKey:@"owner" equalTo:owner];

    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        self.locationObjects = objects;
        [self.tableView reloadData];
    }];
}

#pragma mark - UITableView 

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.locationObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PFObject *locationObject = self.locationObjects[indexPath.row];
    LocationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LocationCell"];

    cell.titleLabel.text = [locationObject objectForKey:@"address"];
    cell.detailLabel.text = [locationObject objectForKey:@"phone"];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectedRow = indexPath.row;
    [AlertBox showAlertFor:self withTitle:@"Location" withMessage:@"Navigate to this location?" leftButton:@"Yes" rightButton:@"No" leftAction:@selector(navigateToSelectedLocationObject) rightAction:nil];
}

#pragma mark - Navigation

- (void)navigateToSelectedLocationObject {
    PFObject *locationObject = self.locationObjects[self.selectedRow];
    NSString *address = [locationObject objectForKey:@"address"];
    [GoogleMapsManager performNavigateToAddress:address];
}

@end
