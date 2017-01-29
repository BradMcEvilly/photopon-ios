
//
//  LocationServicesViewController.m
//  Photopon
//
//  Created by Ante Karin on 11/09/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import "LocationServicesViewController.h"
#import "AlertControllerFactory.h"

@interface LocationServicesViewController() <CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *locationButton;
@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation LocationServicesViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    self.locationButton.layer.cornerRadius = 7;
    self.locationButton.layer.masksToBounds = YES;
}

- (IBAction)locationServicesButtonHandler:(id)sender {
    if ([CLLocationManager locationServicesEnabled]) {
        UIAlertController *alert = [AlertControllerFactory basicAlertWithMessage:@"Location services already enabled, thank you!" completion:^{
            [self.delegate didAllowLocationServices];
        }];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        [self askForLocationServices];
    }
}

- (void)askForLocationServices {
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization];
}

#pragma mark - CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.delegate didAllowLocationServices];
    }
}
@end
