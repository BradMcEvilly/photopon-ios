//
//  CouponWrapper.m
//  Photopon
//
//  Created by Hayk Hayotsyan on 15/7/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CouponWrapper.h"
#import "AlertBox.h"

@implementation CouponWrapper

@synthesize obj;


+ (CouponWrapper*) fromObject:(PFObject*)object {
    CouponWrapper* newWrapper = [CouponWrapper new];
    newWrapper.obj = object;
    return newWrapper;
}

-(void)giveCoupon {
    NSArray* allPFCoupons = GetNearbyCouponsPF();
    for (int i = 0; i < [allPFCoupons count]; ++i) {
        PFObject* o = allPFCoupons[i];
        
        if ([o.objectId isEqualToString:self.obj.objectId]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Goto_AddPhotopon" object:nil userInfo:@{
                                                                                                                 @"index": @(i)
                                                                                                                }];
            return;
        }
    }

    
}


-(void) getCoupon {

    NSNumber* giveToGet = [self.obj valueForKey:@"givetoget"];
    
    PFUser* user = [PFUser currentUser];
    
    PFQuery *query = [PFQuery queryWithClassName:@"PerUserShare"];
    [query includeKey:@"user"];
    [query includeKey:@"coupon"];
    [query includeKey:@"friend"];
    
    [query whereKey:@"user" equalTo:user];
    [query whereKey:@"coupon" equalTo:self.obj];
    
    
    [query countObjectsInBackgroundWithBlock:^(int number, NSError * _Nullable error) {
        if (number >= [giveToGet integerValue]) {
            [AlertBox showMessageFor:self withTitle:@"Are you sure?"
                         withMessage:@"You can redeem coupon once. Are you sure you want to redeem it now?"
                          leftButton:@"Cancel"
                         rightButton:@"Redeem"
                          leftAction:nil
                         rightAction:@selector(redeemCoupon)];
            
        } else {
            int numNeeded = [giveToGet integerValue] - number;
            
            if (number == 0) {
                [AlertBox showMessageFor:self withTitle:@"Share it"
                             withMessage:[NSString stringWithFormat:@"You need to share this coupon with %i friend%s before you can get it.", numNeeded, ((numNeeded > 1) ? "s" : "")]
                              leftButton:@"Cancel"
                             rightButton:@"Share Now!"
                              leftAction:nil
                             rightAction:@selector(giveCoupon)];
            } else {
                [AlertBox showMessageFor:self withTitle:@"Not enough shares"
                             withMessage:[NSString stringWithFormat:@"You need to share this coupon with %i more friend%s before you can get it.", numNeeded, ((numNeeded > 1) ? "s" : "")]
                              leftButton:@"Cancel"
                             rightButton:@"Share Now!"
                              leftAction:nil
                             rightAction:@selector(giveCoupon)];
            }
            
            
            
        }
    }];
}


@end
