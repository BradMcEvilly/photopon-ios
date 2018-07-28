//
//  PPTools.m
//  Photopon
//
//  Created by Damien Rottemberg on 2/16/18.
//  Copyright © 2018 Photopon. All rights reserved.
//

#import "PPTools.h"


@implementation PPTools

static  CLLocationManager* _locationManager = nil;
static  NSString* _countryID = nil;

+(int) isLocationEnabled{

    if([CLLocationManager locationServicesEnabled]){
        switch ([CLLocationManager authorizationStatus]) {
            case kCLAuthorizationStatusDenied:
                return 1;
                break;
                
            case kCLAuthorizationStatusNotDetermined:
                return 0;
                break;
            case kCLAuthorizationStatusRestricted:
                return 1;
                break;
            case kCLAuthorizationStatusAuthorizedAlways:
                PPTools.countryID;
                return 2;
                break;
            case kCLAuthorizationStatusAuthorizedWhenInUse:
                PPTools.countryID;
                return 2;
                break;
            default:
                break;
        }
    }
    return 1;
}

+(void) enableLocation:(id<CLLocationManagerDelegate>)delegate{
    if([CLLocationManager locationServicesEnabled]){
        if([PPTools isLocationEnabled] == 1){
            NSString *settings = UIApplicationOpenSettingsURLString;
            NSURL *settingsURL = [NSURL URLWithString:settings];
            [[UIApplication sharedApplication]openURL:settingsURL options:@{} completionHandler:^(BOOL success) {
                
            }];
        }else if([PPTools isLocationEnabled] == 0){
            
            PPTools.locationManager.delegate = delegate;
            [PPTools.locationManager requestWhenInUseAuthorization];
            
        }
        NSString*  c = PPTools.countryID;
    }else{
        
        PPTools.locationManager.delegate = delegate;
        [PPTools.locationManager requestWhenInUseAuthorization];
        
    }
    
}
      
      
      + (CLLocationManager *)locationManager {
          if (_locationManager == nil) {
              _locationManager = [CLLocationManager new];
          }
          return _locationManager;
      }
      
      + (void)setLocationManager:(CLLocationManager *)newIdentifier {
          _locationManager = newIdentifier;
      }


+ (NSString *)countryID {
    if (_countryID == nil) {
        
        [PPTools.locationManager startUpdatingLocation];
        CLLocation *currentLocation  =  PPTools.locationManager.location;
        [PPTools.locationManager stopUpdatingLocation];
        
        
        CLGeocoder *reverseGeocoder = [[CLGeocoder alloc] init];
        
        [reverseGeocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error)
         {
             if (error){
                 return;
             }
             
             
             
             CLPlacemark *myPlacemark = [placemarks objectAtIndex:0];
             _countryID =  myPlacemark.ISOcountryCode;
             
         }];
    }
    return _countryID;
}

+ (void)setCountryID:(NSString *)countryID {
    _countryID = countryID;
}

@end
