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


void GetMyFriends(ResultBlock block) {
    PFUser* userId = [PFUser currentUser];
    
    PFQuery *query1 = [PFQuery queryWithClassName:@"Friends"];
    [query1 whereKey:@"user1" equalTo:userId];
    
    PFQuery *query2 = [PFQuery queryWithClassName:@"Friends"];
    [query2 whereKey:@"user2" equalTo:userId];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:@[query1,query2]];
    [query includeKey:@"user1"];
    [query includeKey:@"user2"];
    
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        NSMutableArray* resolved = [NSMutableArray array];
        for (PFObject* object in results) {

            PFUser* user1 = [object valueForKey:@"user1"];
            PFUser* user2 = [object valueForKey:@"user2"];
            
            PFUser* otherUser = [PFUser currentUser] == user1 ? user2 : user1;
            //[otherUser fetchIfNeeded];
            [resolved addObject:otherUser];
        };
        
        
        block(resolved, error);
    }];
}



void GetMyFriendRequests(ResultBlock block) {
    PFUser* userId = [PFUser currentUser];
    
    PFQuery *query = [PFQuery queryWithClassName:@"FriendRequests"];
    [query includeKey:@"to"];
    [query whereKey:@"from" equalTo:userId];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        NSMutableArray* resolved = [NSMutableArray array];
        for (PFObject* object in results) {
            
            PFUser* to = [object valueForKey:@"to"];
            [resolved addObject:to];
        };
        
        
        block(resolved, error);
    }];
}


void GetSearchSuggestions(NSString* searchText, ResultBlock block) {
    
    
    PFQuery *query1 = [PFUser query];
    PFQuery *query2 = [PFUser query];
    
    
    [query1 whereKey:@"username" containsString:searchText];
    [query2 whereKey:@"email" containsString:searchText];
    PFQuery *query = [PFQuery orQueryWithSubqueries:@[query1,query2]];
    
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        
        NSMutableArray* filtered = [NSMutableArray array];
        
        GetMyFriends(^(NSArray *friends, NSError *error) {
            GetMyFriendRequests(^(NSArray* requests, NSError *error) {
               
                
                for (PFObject* user in results) {
                    
                    bool isMyFriend = false;
                    bool isRequest = false;
                    
                    NSString* userId = [user objectId];

                    for (PFObject* myFriend in friends) {
                        NSString* myFriendId = [myFriend objectId];
                        if ([myFriendId isEqualToString:userId]) {
                            isMyFriend = true;
                            break;
                        }
                    }
                    
                    for (PFObject* myRequests in requests) {
                        NSString* myRequestId = [myRequests objectId];

                        if ([myRequestId isEqualToString:userId]) {
                            isRequest = true;
                            break;
                        }
                    }
                    
                    
                    if (!isMyFriend && !isRequest && ![userId isEqualToString:[[PFUser currentUser] objectId]]) {
                        [filtered addObject:user];
                    }
                    
                }
                
                block(filtered, error);

                
            });
            
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
    NSLog([user objectId]);
    
    PFQuery *query = [PFQuery queryWithClassName:@"Wallet"];
    //[query includeKey:@"photopon"];
    //[query includeKey:@"photopon.coupon"];
    //[query includeKey:@"photopon.creator"];
    //[query includeKey:@"photopon.coupon.company"];
    
    [query whereKey:@"user" equalTo:user];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        block(results, error);
    }];
}

void CreateFriendRequestNotification(PFUser* toUser) {
    PFObject *notification = [PFObject objectWithClassName:@"Notifications"];
    
    notification[@"to"] = toUser;
    notification[@"assocUser"] = [PFUser currentUser];
    notification[@"type"] = @"FRIEND";
    
    [notification saveInBackground];
}


void CreatePhotoponNotification(PFUser* toUser, PFObject* photopon) {
    PFObject *notification = [PFObject objectWithClassName:@"Notifications"];
    
    notification[@"to"] = toUser;
    notification[@"assocPhotopon"] = photopon;
    notification[@"assocUser"] = [PFUser currentUser];

    notification[@"type"] = @"PHOTOPON";
    
    [notification saveInBackground];
    
    
}




