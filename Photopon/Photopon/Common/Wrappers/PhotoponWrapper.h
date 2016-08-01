//
//  PhotoponWrapper.h
//  Photopon
//
//  Created by Hayk Hayotsyan on 30/7/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhotoponWrapper : NSObject

+ (PhotoponWrapper*)fromObject: (PFObject*)object;
- (void)redeem;

@property (assign) PFObject* photopon;


@end
