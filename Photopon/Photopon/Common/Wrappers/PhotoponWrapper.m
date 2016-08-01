//
//  PhotoponWrapper.m
//  Photopon
//
//  Created by Hayk Hayotsyan on 30/7/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import "PhotoponWrapper.h"
#import "AlertBox.h"

@implementation PhotoponWrapper

@synthesize photopon;


+(PhotoponWrapper*)fromObject:(PFObject*)object {
    PhotoponWrapper* newWrapper = [PhotoponWrapper new];
    newWrapper.photopon = object;
    return newWrapper;
}



-(void) redeem {
    PFObject* coupon = [photopon objectForKey:@"coupon"];
    
    [photopon incrementKey:@"numRedeemed"];
    [photopon saveInBackground];
    
    [coupon incrementKey:@"numRedeemed"];
    [coupon saveInBackground];
    
    SendGAEvent(@"user_action", @"wallet", @"redeem_clicked");
    
    
    [AlertBox showMessageFor:self withTitle:@"Your coupon"
                 withMessage:[NSString stringWithFormat:@"%@ %@", @"Your coupon code is: ", [coupon objectForKey:@"code"]]
                  leftButton:nil
                 rightButton:@"Awesome!"
                  leftAction:nil
                 rightAction:nil];
    
    
    
    CreateRedeemedNotification([photopon valueForKey:@"creator"], photopon);
    CreateRedeemedLog([photopon valueForKey:@"creator"], coupon);
    

}

@end