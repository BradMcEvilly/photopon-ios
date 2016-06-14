//
//  ChatBasePresentableModel.h
//  Photopon
//
//  Created by Roman Temchenko on 2016-06-10.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatBasePresentableModel : NSObject

@property (nonatomic, assign, getter=isCurrentUser) BOOL currentUser;

@end
