//
//  AvailabilityManager.h
//  Photopon
//
//  Created by Ante Karin on 25/06/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AvailabilityManager : NSObject

+ (void)checkAvailabilityForZipcode:(NSString *)zipcode completion:(void (^) (BOOL))completion;
+ (void)checkAvailabilityWithLocation:(CLLocation *)location completion:(void (^) (BOOL))completion;

@end
