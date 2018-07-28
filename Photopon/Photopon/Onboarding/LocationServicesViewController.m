
//
//  LocationServicesViewController.m
//  Photopon
//
//  Created by Ante Karin on 11/09/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import "LocationServicesViewController.h"
#import "AlertControllerFactory.h"
#import "PPTools.h"

@interface LocationServicesViewController() <CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *locationButton;
@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation LocationServicesViewController {
    
    BOOL initStateLocation;
    
    
}

-(void)viewDidLoad {
    [super viewDidLoad];
    self.locationButton.layer.cornerRadius = 7;
    self.locationButton.layer.masksToBounds = YES;
    
    
    
    
    initStateLocation = [PPTools isLocationEnabled];
    
    [self checkLocation];
    
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWilEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    [self checkLocation];
}

-(void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) appWilEnterForeground:(NSNotification *) note {
     [self checkLocation];
    if(initStateLocation == NO && [PPTools isLocationEnabled] == 2){
         [self.delegate didAllowLocationServices];
    }
}

-(void) checkLocation{
    
    if([PPTools isLocationEnabled] == 2){
        [self.locationButton setTitle:@"Already Enabled" forState:UIControlStateNormal];
        [self.locationButton setEnabled:NO];
        [self.locationButton setBackgroundColor:[UIColor lightGrayColor]];
    }else{
        [self.locationButton setTitle:@"Enable Location Services" forState:UIControlStateNormal];
        [self.locationButton setEnabled:YES];
        [self.locationButton setBackgroundColor:[UIColor colorWithRed:47.0/255.0 green:157.0/255.0 blue:71.0/255.0 alpha:1]];
    }
}

- (IBAction)locationServicesButtonHandler:(id)sender {
    
    if([PPTools isLocationEnabled] == 2){
        [self.delegate didAllowLocationServices];
    }else{
        [PPTools enableLocation:self];
    }
    
    
}

- (void)askForLocationServices {
    [PPTools enableLocation:self];
}

#pragma mark - CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.delegate didAllowLocationServices];
    }
}
@end
