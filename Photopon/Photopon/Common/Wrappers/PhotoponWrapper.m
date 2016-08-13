//
//  PhotoponWrapper.m
//  Photopon
//
//  Created by Hayk Hayotsyan on 30/7/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import "PhotoponWrapper.h"
#import "AlertBox.h"


@implementation PFUserPlaceholder

+(PFUserPlaceholder*)create: (NSString*)phoneNumber {
    PFUserPlaceholder* obj = [PFUserPlaceholder new];
    obj.phoneNumber = phoneNumber;
    return obj;
}

-(NSString*)username {
    return phoneNumberFromString(_phoneNumber);
}

-(NSString*)getId {
    return _phoneNumber;
}

@end



@interface UserCache : NSObject

-(BOOL)hasUser: (NSString*) objid;
-(id)getUser: (NSString*) objid;
-(void)setUser: (NSString*)objid forUser:(id)user;

@end


@implementation UserCache: NSObject

NSMutableDictionary* cachedUsers;

+ (UserCache*) instance {
    static UserCache *sharedMyManager = nil;
    @synchronized(self) {
        if (sharedMyManager == nil) {
            sharedMyManager = [[UserCache alloc] init];
        }
    }
    return sharedMyManager;
}

-(BOOL)hasUser: (NSString*) objid {
    if (cachedUsers[objid]) {
        return YES;
    } else {
        return NO;
    }
}


-(id)getUser: (NSString*) objid {
    return cachedUsers[objid];
}


-(void)setUser: (NSString*)objid forUser:(id)user {
    if (!cachedUsers) {
        cachedUsers = [NSMutableDictionary new];
    }
    [cachedUsers setObject:user forKey:objid];
}


@end







@interface ExecutionQueue : NSObject

-(dispatch_queue_t)getQueue;

@property (retain) dispatch_queue_t the_queue;

@end


@implementation ExecutionQueue: NSObject


+ (ExecutionQueue*) instance {
    static ExecutionQueue *sharedMyQueue = nil;
    @synchronized(self) {
        if (sharedMyQueue == nil) {
            sharedMyQueue = [[ExecutionQueue alloc] init];
            sharedMyQueue.the_queue = dispatch_queue_create("User resolver", DISPATCH_QUEUE_SERIAL);
        }
    }
    return sharedMyQueue;
}

-(dispatch_queue_t)getQueue {
    return _the_queue;
}



@end






@implementation PhotoponWrapper
{
    
}

@synthesize photopon;


+(PhotoponWrapper*)fromObject:(PFObject*)object {
    PhotoponWrapper* newWrapper = [PhotoponWrapper new];
    newWrapper.photopon = object;
    return newWrapper;
}

- (void)grabUsers: (PhotoponUsersBlock)block {
    
    
    NSArray* users = [photopon objectForKey:@"users"];
    NSMutableArray* mutable = [NSMutableArray new];
    BOOL foundEverything = YES;
    
    for (NSString* objid in users) {
        
        if ([[UserCache instance] hasUser:objid] ) {
            [mutable addObject: [[UserCache instance] getUser:objid] ];
        } else {
            foundEverything = NO;
        }
    }
    

    if (!foundEverything) {
        
        dispatch_async([[ExecutionQueue instance] getQueue], ^{
            
            
            NSArray* users = [photopon objectForKey:@"users"];
            NSMutableArray* mutable = [NSMutableArray new];
            
            for (NSString* objid in users) {
                PFQuery * query = [PFUser query];
                
                if ([[UserCache instance] hasUser:objid] ) {
                    [mutable addObject: [[UserCache instance] getUser:objid] ];
                } else {
                    
                    [query whereKey:@"objectId" equalTo:objid];
                    
                    PFUser* u = [query getFirstObject];
                    if (u) {
                        [mutable addObject:u];
                        [[UserCache instance] setUser:objid forUser:u];
                    } else {
                        
                        
                        PFQuery* secondQuery = [PFUser query];
                        [secondQuery whereKey:@"phone" equalTo:objid];
                        PFUser* u1 = [secondQuery getFirstObject];
                        
                        if (u1) {
                            [mutable addObject:u1];
                            [[UserCache instance] setUser:objid forUser:u1];
                        } else {
                            PFUserPlaceholder* userHolder = [PFUserPlaceholder create:objid];
                            [mutable addObject:userHolder];
                            [[UserCache instance] setUser:objid forUser:userHolder];
                        }
                    }
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                block(mutable);
            });

            
        });
        
    } else {
        block(mutable);
    }
    
    
}


- (void)getStatusForUser: (PFUser*)user withBlock:(PhotoponStatusBlock)status {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        PFQuery * walletQuery = [PFQuery queryWithClassName:@"Wallet"];
        [walletQuery whereKey:@"photopon" equalTo:photopon];
        [walletQuery whereKey:@"user" equalTo:user];
        
        if ([walletQuery countObjects] > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                status(@"Saved");
            });
            return;
        }
        
        PFQuery *redeemQuery = [PFQuery queryWithClassName:@"RedeemedCoupons"];
        [redeemQuery whereKey:@"user" equalTo:user];
        [redeemQuery whereKey:@"coupon" equalTo:[photopon objectForKey:@"coupon"]];
        
        
        if ([redeemQuery countObjects] > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                status(@"Redeemed");
            });
            return;
        }
        
        
        
        PFQuery *notificationQuery = [PFQuery queryWithClassName:@"Notifications"];
        [notificationQuery whereKey:@"to" equalTo:user];
        [notificationQuery whereKey:@"type" equalTo:@"PHOTOPON"];
        [notificationQuery whereKey:@"assocPhotopon" equalTo:photopon];
        
        
        if ([notificationQuery countObjects] > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                status(@"Notified");
            });
            return;
        }
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            status(@"Dismissed");
        });
    });

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