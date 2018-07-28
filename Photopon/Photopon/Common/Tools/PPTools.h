//
//  PPTools.h
//  Photopon
//
//  Created by Damien Rottemberg on 2/16/18.
//  Copyright © 2018 Photopon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PPTools : NSObject


@property (class,strong, nonatomic) CLLocationManager *locationManager;
@property (class,strong, nonatomic) NSString *countryID;


+(int) isLocationEnabled;
+(void) enableLocation:(id<CLLocationManagerDelegate>)delegate;

@end
