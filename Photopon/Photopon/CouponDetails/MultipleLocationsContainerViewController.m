//
//  MultipleLocationsContainerViewController.m
//  Photopon
//
//  Created by Ante Karin on 09/10/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import "MultipleLocationsContainerViewController.h"
#import "CouponLocationsTableViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface MultipleLocationsContainerViewController ()

@property (nonatomic, strong) NSArray *locationObjects;

@property (nonatomic, weak) CouponLocationsTableViewController *listVC;
@property (nonatomic, weak) UIViewController *mapVC;

@end

@implementation MultipleLocationsContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSArray *couponLocations = [self.coupon objectForKey:@"locations"];
    if (couponLocations.count > 0) {
        [self retrieveLocationsObjectsWithIDs:couponLocations];
    } else {
        [self retrieveAllLocationsForOwnerID:[self.coupon objectForKey:@"owner"]];
    }
}

-(void)setLocationObjects:(NSArray *)locationObjects {
    _locationObjects = locationObjects;
    self.listVC.locationObjects = locationObjects;
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [segue.identifier isEqualToString:@"EmbedList"] ? (self.listVC = segue.destinationViewController) : (self.mapVC = segue.destinationViewController);
}

@end
