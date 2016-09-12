
//
//  LocationServicesViewController.m
//  Photopon
//
//  Created by Ante Karin on 11/09/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import "LocationServicesViewController.h"

@interface LocationServicesViewController() <CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *locationButton;

@end

@implementation LocationServicesViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    self.locationButton.layer.cornerRadius = 7;
    self.locationButton.layer.masksToBounds = YES;
}

- (IBAction)locationServicesButtonHandler:(id)sender {
    CLLocationManager *manager = [CLLocationManager new];
    manager.delegate = self;
    [manager requestWhenInUseAuthorization];
}

#pragma mark - CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.delegate didAllowLocationServices];
    }
}
@end
