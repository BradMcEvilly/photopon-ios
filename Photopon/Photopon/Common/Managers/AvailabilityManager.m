//
//  AvailabilityManager.m
//  Photopon
//
//  Created by Ante Karin on 25/06/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import "AvailabilityManager.h"
#import <Parse/Parse.h>
#import <PFObject.h>
#import "DBAccess.h"
#import <CoreLocation/CoreLocation.h>

NSString * const NOTIFICATION_PHOTOPON_AVAILABLE = @"NOTIFICATION_PHOTOPON_AVAILABLE";
static BOOL photoponAvailable = YES;

@implementation AvailabilityManager

+ (void)checkAvailabilityForZipcode:(NSString *)zipcode completion:(void (^) (BOOL))completion {
    CheckAppAvailabilityForZipcode(zipcode, ^(BOOL available, NSError *error) {
        [self setPhotoponAvailable:available];
        if (available) {
            completion(YES);
        } else {
            
            
#ifdef DEBUG
            completion(YES);
#else
            completion(NO);
#endif
        }
    });
}

+ (void)checkAvailabilityWithLocation:(CLLocation *)location completion:(void (^) (BOOL))completion {
    CLGeocoder *geocoder = [[CLGeocoder alloc]init];

    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        CLPlacemark *placemark = placemarks.firstObject;
        NSString *zipcode = placemark.postalCode;

        if (zipcode) {
            [self checkAvailabilityForZipcode:zipcode completion:completion];
        } else {
            if (completion) {
                
#ifdef DEBUG
                completion(YES);
#else
                completion(NO);
#endif
      
            }
        }
    }];
}

+(BOOL)photoponAvailable {
    return photoponAvailable;
}

+ (void)setPhotoponAvailable:(BOOL)available {
    if (available != photoponAvailable) {
        photoponAvailable = available;
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_PHOTOPON_AVAILABLE object:nil];
    } else {
        photoponAvailable = available;
    }
}

@end
