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

void CreateFriendRequestNotification(PFUser* toUser);
void CreatePhotoponNotification(PFUser* toUser, PFObject* photopon);
void CreateMessageNotification(PFUser* toUser, NSString* content);




void GetCoupons(ResultBlock block);
void GetCouponsByLocation(float latitude, float longitude, ResultBlock block);

void SaveImage(NSString* fileName, UIImage* image, FileResultBlock block);


#endif
