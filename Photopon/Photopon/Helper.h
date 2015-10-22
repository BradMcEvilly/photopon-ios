//
//  Helper.h
//  Photopon
//
//  Created by Hayk Hayotsyan on 16/8/15.
//  Copyright (c) 2015 Photopon. All rights reserved.
//

#ifndef Photopon_Helper_h
#define Photopon_Helper_h
#import <Foundation/Foundation.h>
@import UIKit;
@import CoreLocation;



@protocol CouponUpdateDelegate <NSObject>

- (void) couponsUpdated;

@end


extern NSMutableArray* couponsNearby;

UIImageView* CreateFAImage(NSString* type, CGFloat size);



void UpdateNearbyCoupons();



NSArray* GetNearbyCoupons();
NSArray* GetNearbyCouponsPF();

void AddCouponUpdateListener(id<CouponUpdateDelegate> delegate);
void RemoveCouponUpdateListener(id<CouponUpdateDelegate> delegate);





@interface LocationHandler : NSObject<CLLocationManagerDelegate>

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations;
- (void)getCouponsForLocation:(CLLocation*)location;

@end





#endif
