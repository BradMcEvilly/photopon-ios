//
//  DBAccess.h
//  Photopon
//
//  Created by Hayk Hayotsyan on 16/8/15.
//  Copyright (c) 2015 Photopon. All rights reserved.
//

#ifndef Photopon_DBAccess_h
#define Photopon_DBAccess_h


#import <Foundation/Foundation.h>
#import "Parse/Parse.h"

typedef void (^ResultBlock)(NSArray *results, NSError *error);

typedef void (^FriendSuggestionResultBlock)(PFUser *user, NSArray* myFriends);

typedef void (^FileResultBlock)(PFFile* file, NSError *error);


void GetMyFriends(ResultBlock block);
void GetUserByPhone(NSString* phone, FriendSuggestionResultBlock block);


void GetSearchSuggestion(NSString* searchText, FriendSuggestionResultBlock block);

void GetNotifications(ResultBlock block);
void GetWalletItems(ResultBlock block);

void CreateAddFriendNotification(PFUser* toUser);
void RemoveAddFriendNotification(PFUser* userToRemove);

void CreatePhotoponNotification(PFUser* toUser, PFObject* photopon);
void CreateMessageNotification(PFUser* toUser, NSString* content);

void CreateAddWalletNotification(PFUser* toUser, PFObject* photopon);
void CreateRedeemedNotification(PFUser* toUser, PFObject* photopon);


void CreateRedeemedLog(PFUser* fromUser, PFObject* coupon);

void GetAppAvailabilityWhitelistedZipcodes(ResultBlock result);

void GetCoupons(ResultBlock block);
void GetCouponsByLocation(float latitude, float longitude, ResultBlock block);

void SaveImage(NSString* fileName, UIImage* image, FileResultBlock block);
BOOL HasPhoneNumber(NSString* message);

#endif
