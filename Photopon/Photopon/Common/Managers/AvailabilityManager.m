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

@implementation AvailabilityManager

+ (void)checkAvailabilityForZipcode:(NSString *)zipcode completion:(void (^) (BOOL))completion {
    GetAppAvailabilityWhitelistedZipcodes(^(NSArray *results, NSError *error) {
        for (NSString *zip in results) {
            if ([zip isEqualToString:zipcode]) {
                if(completion) {completion(YES);}
            }
        }
        if (completion) {completion(NO);}
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
            if (completion) {completion(NO);}
        }
    }];
}

@end
