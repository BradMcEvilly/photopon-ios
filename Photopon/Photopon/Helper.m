    //
//  Helper.m
//  Photopon
//
//  Created by Hayk Hayotsyan on 16/8/15.
//  Copyright (c) 2015 Photopon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Helper.h"
#import "DBAccess.h"
#import "FontAwesome/FAImageView.h"






NSMutableArray* couponsNearby;
NSMutableArray* couponsNearbyPF;

CLLocationManager* locationManager;
LocationHandler* locationHandler;

NSHashTable *couponDelegates;


BOOL isLocationInitialized = NO;


UIImageView* CreateFAImage(NSString* type, CGFloat size) {
    FAImageView *imageView = [[FAImageView alloc] initWithFrame:CGRectMake(0.f, 0.f, size, size)];
    imageView.image = nil;

    imageView.defaultView.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    imageView.defaultView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];

    [imageView setDefaultIconIdentifier:type];
    return imageView;
}







void UpdateNearbyCoupons() {
    if (!isLocationInitialized) {
        isLocationInitialized = YES;
        locationManager = [[CLLocationManager alloc] init];
        locationHandler = [[LocationHandler alloc] init];
        
        couponsNearby = [NSMutableArray array];
        couponsNearbyPF = [NSMutableArray array];
        
    }
    
    
    
    if ([CLLocationManager locationServicesEnabled]) {
        
        locationManager.delegate = locationHandler;
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
            [locationHandler getCouponsForLocation: locationManager.location];
        }
        
        
        [locationManager startUpdatingLocation];
        
    
    }

    
}









NSArray* GetNearbyCoupons() {
    return couponsNearby;
}


NSArray* GetNearbyCouponsPF() {
    return couponsNearbyPF;
}



void AddCouponUpdateListener(id<CouponUpdateDelegate> delegate) {
    [couponDelegates addObject: delegate];
}

void RemoveCouponUpdateListener(id<CouponUpdateDelegate> delegate) {
    [couponDelegates removeObject:delegate];
}







@implementation LocationHandler


- (void)getCouponsForLocation:(CLLocation*)location {
    NSLog(@"%f, %f", location.coordinate.latitude, location.coordinate.longitude);
    
    GetCouponsByLocation(location.coordinate.latitude, location.coordinate.longitude, ^(NSArray *results, NSError *error) {
        [couponsNearby removeAllObjects];
        [couponsNearbyPF removeAllObjects];
        
        for (PFObject* object in results) {
            
            NSString* title = [object objectForKey:@"title"];
            NSString* desc = [object objectForKey:@"description"];
            PFObject* company = [object objectForKey:@"company"];
            PFFile* pic = [company objectForKey:@"image"];
            
            [couponsNearby addObject:@{
                                    @"title": title,
                                    @"desc": desc,
                                    @"pic": pic.url
                                    }];
            
            
            [couponsNearbyPF addObject:object];
        }
        
        for (id<CouponUpdateDelegate> obj in couponDelegates) {
            [obj couponsUpdated];
        }
        
        NSLog(@"Got locations!!!");
    });

}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {

    CLLocation* location = [locations lastObject];
    
    [self getCouponsForLocation:location];
}

@end









