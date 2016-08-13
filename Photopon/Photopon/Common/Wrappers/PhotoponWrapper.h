//
//  PhotoponWrapper.h
//  Photopon
//
//  Created by Hayk Hayotsyan on 30/7/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^PhotoponUsersBlock)(NSArray *results);
typedef void (^PhotoponStatusBlock)(NSString *status);

@interface PFUserPlaceholder : NSObject

+(PFUserPlaceholder*)create: (NSString*)phoneNumber;
-(NSString*)username;
-(NSString*)getId;

@property (assign) NSString* phoneNumber;
@end

@interface PhotoponWrapper : NSObject

+ (PhotoponWrapper*)fromObject: (PFObject*)object;
- (void)redeem;
- (void)grabUsers: (PhotoponUsersBlock)block;
- (void)getStatusForUser: (PFUser*)user withBlock:(PhotoponStatusBlock)status;


@property (assign) PFObject* photopon;


@end
