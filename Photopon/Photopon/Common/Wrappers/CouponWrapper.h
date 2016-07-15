//
//  CouponWrapper.h
//  Photopon
//
//  Created by Hayk Hayotsyan on 25/06/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CouponWrapper : NSObject

+ (CouponWrapper*) fromObject:(PFObject*)object;

- (void) getCoupon;


@property (assign) PFObject* obj;

@end
