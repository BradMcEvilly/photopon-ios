//
//  DBAccess.m
//  Photopon
//
//  Created by Hayk Hayotsyan on 16/8/15.
//  Copyright (c) 2015 Photopon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "DBAccess.h"
#import "Helper.h"
#import "AlertBox.h"

void GetMyFriends(ResultBlock block) {
    PFUser* userId = [PFUser currentUser];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Friends"];
    [query includeKey:@"user2"];
    [query whereKey:@"user1" equalTo:userId];
    
    
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        block(results, error);
    }];
}



void GetUserByPhone(NSString* phone, FriendSuggestionResultBlock block) {
    PFQuery *query = [PFUser query];
    
    [query whereKey:@"phone" equalTo:phone];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        block((PFUser*)object, NULL);
    }];
}



void GetSearchSuggestion(NSString* searchText, FriendSuggestionResultBlock block) {
    
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" equalTo:searchText];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        
        GetMyFriends(^(NSArray *friends, NSError *error) {

            if (!object) {
                block(nil, friends);
                return;
            }
            /*
            PFUser* userId = [PFUser currentUser];
            
            for (int i = 0; i < [friends count]; ++i) {
                PFObject* friendship = [friends objectAtIndex:i];
                PFUser* myFriend = [friendship valueForKey:@"user2"];
                if (myFriend) {
                    if ([[myFriend objectId] isEqualToString:[userId objectId]]) {
                        block(nil, friends);
                        return;
                    }
                }
            }
             */
            
            
            block((PFUser*)object, friends);
        });
        
    }];
}




void GetCoupons(ResultBlock block) {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Coupon"];
    [query includeKey:@"company"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        block(results, error);
    }];
}


void GetCouponsByLocation(float latitude, float longitude, ResultBlock block) {
    PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:latitude longitude:longitude];
    PFQuery *locationQuery = [PFQuery queryWithClassName:@"Location"];

    [locationQuery whereKey:@"location" nearGeoPoint:point withinKilometers:1];
    //
    
    [locationQuery findObjectsInBackgroundWithBlock:^(NSArray *locations, NSError *error) {
        NSMutableSet *ids = [[NSMutableSet alloc] init];
        
        for(PFObject *oneItem in locations) {
            [ids addObject:oneItem.objectId ];
        }
        
        
        NSNumber* serverTime = [PFCloud callFunction:@"ServerTime" withParameters:nil];
        
        PFQuery *couponQuery = [PFQuery queryWithClassName:@"Coupon"];
        [couponQuery includeKey:@"company"];
        [couponQuery whereKey:@"isActive" equalTo:[NSNumber numberWithBool:YES]];
        [couponQuery whereKey:@"expiration" greaterThanOrEqualTo:[NSDate dateWithTimeIntervalSince1970:[serverTime doubleValue]/1000]];
        
        
    
        [couponQuery findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
            
            NSMutableArray *c = [[NSMutableArray alloc] init];
            for (PFObject* coupon in results) {
                
                NSArray* locs = [coupon objectForKey:@"locations"];
                
                for (NSString* locid in locs) {
                    if ([ids containsObject:locid]) {
                        [c addObject:coupon];
                        break;
                    }
                }
                
                if ([locs count] == 0 && [ids count] != 0) {
                    [c addObject:coupon];
                }
                
            }
            block(c, error);
        }];
        
    }];

}



void SaveImage(NSString* fileName, UIImage* image, FileResultBlock block) {
    
    NSData* data = nil;
    
    NSString *extension = [fileName substringFromIndex:MAX((int)[fileName length] - 4, 0)];
    
    if ([extension isEqualToString:@".jpg"]) {
        data = UIImageJPEGRepresentation(image, 0.9f);
    } else {
        data = UIImagePNGRepresentation(image);
    }
    
    PFFile *imageFile = [PFFile fileWithName:fileName data:data];
    [imageFile saveInBackgroundWithBlock:^(BOOL success, NSError* err) {
        if (err) {
            block(nil, err);
            return;
        }
        block(imageFile, nil);
    }];
    
}



void GetNotifications(ResultBlock block) {
    PFUser* user = [PFUser currentUser];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Notifications"];
    [query includeKey:@"to"];
    [query includeKey:@"assocUser"];
    [query includeKey:@"assocPhotopon"];
    [query includeKey:@"assocPhotopon.coupon"];
    [query includeKey:@"assocPhotopon.coupon.company"];
    
    [query whereKey:@"to" equalTo:user];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        block(results, error);
    }];
}

void GetWalletItems(ResultBlock block) {
    PFUser* user = [PFUser currentUser];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Wallet"];
    [query includeKey:@"photopon"];
    [query includeKey:@"photopon.coupon"];
    [query includeKey:@"photopon.creator"];
    [query includeKey:@"photopon.coupon.company"];
    
    [query whereKey:@"user" equalTo:user];
    [query whereKey:@"isUsed" equalTo:[NSNumber numberWithBool:NO]];

    
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        block(results, error);
    }];
}




void CreateAddFriendNotification(PFUser* toUser) {
    
    
    PFQuery *query = [PFQuery queryWithClassName:@"Notifications"];
    
    [query whereKey:@"to" equalTo:toUser];
    [query whereKey:@"assocUser" equalTo:[PFUser currentUser]];
    [query whereKey:@"type" equalTo:@"FRIEND"];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *result, NSError *error) {
        
        if (!result) {
            PFObject *notification = [PFObject objectWithClassName:@"Notifications"];
            
            notification[@"to"] = toUser;
            notification[@"assocUser"] = [PFUser currentUser];
            notification[@"type"] = @"FRIEND";
            
            [notification saveInBackground];
            [RealTimeNotificationHandler sendUpdate:@"NOTIFICATION" forUser:toUser];
        }
    }];
}

void RemoveAddFriendNotification(PFUser* userToRemove) {
    PFQuery *query = [PFQuery queryWithClassName:@"Notifications"];
    
    [query whereKey:@"to" equalTo:userToRemove];
    [query whereKey:@"assocUser" equalTo:[PFUser currentUser]];
    [query whereKey:@"type" equalTo:@"FRIEND"];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *result, NSError *error) {
        
        if (result) {
            [result delete];
            
            [RealTimeNotificationHandler sendUpdate:@"NOTIFICATION" forUser:userToRemove];
        }
    }];
}


void CreateMessageNotification(PFUser* toUser, NSString* content) {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Notifications"];
    
    [query whereKey:@"to" equalTo:toUser];
    [query whereKey:@"assocUser" equalTo:[PFUser currentUser]];
    [query whereKey:@"type" equalTo:@"MESSAGE"];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *result, NSError *error) {
        
        if (result) {
            [result setValue:content forKey:@"content"];
            [result saveInBackground];
            
        } else {
            
            PFObject *notification = [PFObject objectWithClassName:@"Notifications"];
            
            notification[@"to"] = toUser;
            notification[@"type"] = @"MESSAGE";
            notification[@"content"] = content;
            notification[@"assocUser"] = [PFUser currentUser];
            
            [notification saveInBackground];
        }
        
        [RealTimeNotificationHandler sendUpdate:@"NOTIFICATION" forUser:toUser];
    }];

}


void CreatePhotoponNotification(PFUser* toUser, PFObject* photopon) {
    PFObject *notification = [PFObject objectWithClassName:@"Notifications"];
    
    notification[@"to"] = toUser;
    notification[@"assocPhotopon"] = photopon;
    notification[@"assocUser"] = [PFUser currentUser];
    
    notification[@"type"] = @"PHOTOPON";
    
    [notification saveInBackground];
    [RealTimeNotificationHandler sendUpdate:@"NOTIFICATION" forUser:toUser];
    
}



void CreateAddWalletNotification(PFUser* toUser, PFObject* photopon) {
    PFObject *notification = [PFObject objectWithClassName:@"Notifications"];
    
    notification[@"to"] = toUser;
    notification[@"assocPhotopon"] = photopon;
    notification[@"assocUser"] = [PFUser currentUser];
    
    notification[@"type"] = @"ADDWALLET";
    
    [notification saveInBackground];
    [RealTimeNotificationHandler sendUpdate:@"NOTIFICATION" forUser:toUser];
    
}



void CreateRedeemedNotification(PFUser* toUser, PFObject* photopon) {
    PFObject *notification = [PFObject objectWithClassName:@"Notifications"];
    
    notification[@"to"] = toUser;
    notification[@"assocPhotopon"] = photopon;
    notification[@"assocUser"] = [PFUser currentUser];
    
    notification[@"type"] = @"REDEEMED";
    
    [notification saveInBackground];
    [RealTimeNotificationHandler sendUpdate:@"NOTIFICATION" forUser:toUser];
    
}




void CreateRedeemedLog(PFUser* fromUser, PFObject* coupon) {

    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint * _Nullable geoPoint, NSError * _Nullable error) {
        PFObject *redeemLog = [PFObject objectWithClassName:@"Redeem"];
        
        redeemLog[@"to"] = [PFUser currentUser];
        if (fromUser) {
            redeemLog[@"from"] = fromUser;
        }
        redeemLog[@"coupon"] = coupon;
        redeemLog[@"location"] = geoPoint;
        [redeemLog saveInBackground];
    }];
}


@interface PhoneNumberCheckDelegate : NSObject 

+ (PhoneNumberCheckDelegate *)sharedInstance;

@end

@implementation PhoneNumberCheckDelegate

-(void)showSettings {
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    UIStoryboard *st = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:[NSBundle mainBundle]];
    
    UIViewController* mainCtrl = [st instantiateViewControllerWithIdentifier:@"SBSettings"];
    [topController showViewController:mainCtrl sender:nil];
    
    SendGAEvent(@"user_action", @"phone_number_check", @"go_to_settings");
    
}



+ (PhoneNumberCheckDelegate *)sharedInstance
{
    static PhoneNumberCheckDelegate *sharedInstance;
    
    @synchronized(self)
    {
        if (!sharedInstance)
            sharedInstance = [[PhoneNumberCheckDelegate alloc] init];
        
        return sharedInstance;
    }
}


@end



BOOL HasPhoneNumber(NSString* message) {
    
    PFUser* c = [PFUser currentUser];
    if (c && c[@"phone"]) {
        return TRUE;
    }
    
    if (message) {
        
        [AlertBox showAlertFor:[PhoneNumberCheckDelegate sharedInstance] withTitle:@"Number required" withMessage:message leftButton:@"Go to settings" rightButton:@"Later" leftAction:@selector(showSettings) rightAction:nil];

    }
    
    return FALSE;
}



