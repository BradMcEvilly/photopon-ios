//
//  CouponWrapper.h
//  Photopon
//
//  Created by Hayk Hayotsyan on 25/06/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^BooleanCallback)(BOOL value);

@interface CouponWrapper : NSObject

+ (CouponWrapper*) fromObject:(PFObject*)object;
- (void) getCoupon;
- (void) isRedeemed:(BooleanCallback)callback;

@property (assign) PFObject* obj;

@end
