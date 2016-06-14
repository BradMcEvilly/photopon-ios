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
#import "PubNubWrapper.h"
#import "FontAwesome/FAImageView.h"
#import <PubNub/PubNub+Subscribe.h>
#import <PubNub/PNSubscriberResults.h>
#import <PubNub/PubNub+Core.h>
#import <PubNub/PNConfiguration.h>
#import <PubNub/PubNub+Publish.h>
#import <Parse/Parse.h>
#import "AlertBox.h"





NSMutableArray* couponsNearby;
NSMutableArray* couponsNearbyPF;

CLLocationManager* locationManager;
LocationHandler* locationHandler;

NSHashTable *couponDelegates;

NSMutableDictionary* notificationListeners;

RealTimeNotificationHandler* rtUpdateInstance;



BOOL isLocationInitialized = NO;


void SendGAEvent(NSString* category, NSString* action, NSString* label) {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:category     // Event category (required)
                                                          action:action  // Event action (required)
                                                           label:label          // Event label
                                                           value:nil] build]];    // Event value
}


UIImage* MakeImageNegative(UIImage* image) {
    
    UIGraphicsBeginImageContext(image.size);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeCopy);
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeDifference);
    //CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(),[UIColor whiteColor].CGColor);
    //CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, image.size.width, image.size.height));
    UIImage *negativeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return negativeImage;
    
}


UIImage* ImageWithWhiteBackground(UIImage* image) {
    UIImage *negative = MakeImageNegative(image);
    
    UIGraphicsBeginImageContext(negative.size);
    CGContextSetRGBFillColor (UIGraphicsGetCurrentContext(), 1, 1, 1, 1);
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = CGPointZero;
    thumbnailRect.size.width = negative.size.width;
    thumbnailRect.size.height = negative.size.height;
    
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0.0, negative.size.height);
    CGContextScaleCTM(UIGraphicsGetCurrentContext(), 1.0, -1.0);
    CGContextFillRect(UIGraphicsGetCurrentContext(), thumbnailRect);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), thumbnailRect, negative.CGImage);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}


UIImage* MaskImageWithColor(UIImage* image, UIColor* color) {
    
    UIImage *formattedImage = ImageWithWhiteBackground(image);
    
    CGRect rect = {0, 0, formattedImage.size.width, formattedImage.size.height};
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);
    UIImage *tempColor = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGImageRef maskRef = [formattedImage CGImage];
    CGImageRef maskcg = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                          CGImageGetHeight(maskRef),
                                          CGImageGetBitsPerComponent(maskRef),
                                          CGImageGetBitsPerPixel(maskRef),
                                          CGImageGetBytesPerRow(maskRef),
                                          CGImageGetDataProvider(maskRef), NULL, false);
    
    CGImageRef maskedcg = CGImageCreateWithMask([tempColor CGImage], maskcg);
    CGImageRelease(maskcg);
    UIImage *result = [UIImage imageWithCGImage:maskedcg];
    CGImageRelease(maskedcg);
    
    return result;
}




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
            [AlertBox showAlertFor:locationHandler withTitle:@"No permission" withMessage:@"Location services must be enabled in order to use Photopon." leftButton:@"Go to settings" rightButton:@"Later" leftAction:@selector(showSettings) rightAction:nil];
                        
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


NSString* NumbersFromFormattedPhone(NSString* formatted) {
    
    return [[formatted componentsSeparatedByCharactersInSet:
                            [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                           componentsJoinedByString:@""];
}



int DaysBetween(NSDate* from, NSDate* to) {

    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:NSCalendarUnitDay fromDate:from toDate:to options:0];
    return [components day] + 1;
}


NSArray* GetNearbyCoupons() {
    return couponsNearby;
}


NSArray* GetNearbyCouponsPF() {
    return couponsNearbyPF;
}



void AddCouponUpdateListener(id<CouponUpdateDelegate> delegate) {
    if (couponDelegates == nil) {
        couponDelegates = [[NSHashTable alloc] init];
    }
    [couponDelegates addObject: delegate];
    NSLog(@"Currently %lu coupon update listeners", [couponDelegates count]);
}

void RemoveCouponUpdateListener(id<CouponUpdateDelegate> delegate) {
    [couponDelegates removeObject:delegate];
}





@implementation LocationHandler


- (void)getCouponsForLocation:(CLLocation*)location {
    NSLog(@"Getting coupons for location %f, %f", location.coordinate.latitude, location.coordinate.longitude);
    
    GetCouponsByLocation(location.coordinate.latitude, location.coordinate.longitude, ^(NSArray *results, NSError *error) {
        [couponsNearby removeAllObjects];
        [couponsNearbyPF removeAllObjects];
        
        NSLog(@"Got %lu coupons!", [results count]);
        
        for (PFObject* object in results) {
            
            NSString* title = [object objectForKey:@"title"];
            NSString* desc = [object objectForKey:@"description"];
            PFObject* company = [object objectForKey:@"company"];
            PFFile* pic = [company objectForKey:@"image"];
            
            [couponsNearby addObject:@{
                                    @"title": title,
                                    @"desc": desc,
                                    @"pic": pic.url,
                                    @"expiration": [object objectForKey:@"expiration"]
                                    }];
            
            
            [couponsNearbyPF addObject:object];
        }
        
        NSLog(@"Broadcasting to %lu delegates", [couponDelegates count]);
        
        for (id<CouponUpdateDelegate> obj in couponDelegates) {
            [obj couponsUpdated];
        }
        
    });

}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {

    CLLocation* location = [locations lastObject];
    
    [self getCouponsForLocation:location];
}

-(void)showSettings {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}


@end



@implementation RealTimeNotificationHandler


- (void)client:(PubNub *)client didReceiveMessage:(PNMessageResult*)msg {
    
    NSDictionary* data = msg.data.message;
    
    
    if (![data[@"type"] isEqualToString:@"NOTIFICATION"]) {
        return;
    }
    
    
    NSString* message = [data valueForKey:@"notification"];
    NSString* notType = [NSString stringWithFormat:@"%@.", message];
    
    NSArray* keys = [notificationListeners allKeys];
    for (NSString* key in keys) {
        if ([key hasPrefix:notType]) {
            NotificationBlock block = notificationListeners[key];
            block(message);
        }
    }
    
}



+ (void)setupManager {
    
    if (rtUpdateInstance) {
        return;
    }
    
    PubNub* pubnub = GetPubNub();
    PFUser* current = [PFUser currentUser];
    
    NSString* channel = [NSString stringWithFormat:@"%@_NOTIFICATIONS", [current objectId]];
    
    [pubnub subscribeToChannels:@[channel] withPresence:false];
    
    notificationListeners = [[NSMutableDictionary alloc] init];
    
    rtUpdateInstance = [RealTimeNotificationHandler alloc];
    [pubnub addListener:rtUpdateInstance];
}


+ (void)sendUpdate:(NSString*)update forUser:(PFUser*)user {
    PubNub* pubnub = GetPubNub();
    
    NSString* channel = [NSString stringWithFormat:@"%@_NOTIFICATIONS", [user objectId]];

    
    [pubnub publish:@{
        @"type" : @"NOTIFICATION",
        @"notification": update
    } toChannel:channel withCompletion:^(PNPublishStatus *status) {
              
              
    }];
}



+ (void)addListener:(NSString*)type withBlock:(NotificationBlock)block {
    [RealTimeNotificationHandler setupManager];
    [notificationListeners setObject:block forKey:type];
}

+ (void)removeListener:(NSString*)type {
    [RealTimeNotificationHandler setupManager];
    [notificationListeners removeObjectForKey:type];
}



@end





















