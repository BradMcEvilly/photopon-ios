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
#import <PubNub/PNObjectEventListener.h>
#import <Parse/Parse.h>

@import UIKit;
@import CoreLocation;



@protocol CouponUpdateDelegate <NSObject>
- (void) couponsUpdated;
@end



typedef void (^NotificationBlock)(NSString* notificationType);



extern NSMutableArray* couponsNearby;

UIImageView* CreateFAImage(NSString* type, CGFloat size);
NSString* NumbersFromFormattedPhone(NSString* formatted);


void SendGAEvent(NSString* category, NSString* action, NSString* label);


NSArray* GetNearbyCoupons();
NSArray* GetNearbyCouponsPF();
void UpdateNearbyCoupons();



void AddCouponUpdateListener(id<CouponUpdateDelegate> delegate);
void RemoveCouponUpdateListener(id<CouponUpdateDelegate> delegate);


int DaysBetween(NSDate* from, NSDate* to);
NSString* phoneNumberFromString(NSString* number);


UIImage* MakeImageNegative(UIImage* image);
UIImage* ImageWithWhiteBackground(UIImage* image);
UIImage* MaskImageWithColor(UIImage* image, UIColor* color);


CLLocation* GetCurrentLocation();
CLLocationManager* GetLocationManager();

@interface LocationHandler : NSObject<CLLocationManagerDelegate>

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations;
- (void)getCouponsForLocation:(CLLocation*)location;
- (void)showSettings;

@property (nonatomic, assign) CLAuthorizationStatus authorizationStatus;

@end


@interface RealTimeNotificationHandler : NSObject<PNObjectEventListener>

+ (void)setupManager;
+ (void)sendUpdate:(NSString*)update forUser:(PFUser*)user;

+ (void)addListener:(NSString*)type withBlock:(NotificationBlock)block;
+ (void)removeListener:(NSString*)type;

@end






#endif
