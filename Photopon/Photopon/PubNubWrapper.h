//
//  PubNubWrapper.h
//  Photopon
//
//  Created by Hayk Hayotsyan on 18/8/15.
//  Copyright (c) 2015 Photopon. All rights reserved.
//

#ifndef Photopon_PubNubWrapper_h
#define Photopon_PubNubWrapper_h

#import <Foundation/Foundation.h>
#import <PubNub/PubNub+Core.h>


PubNub* GetPubNub();

void PubNubSendMessage(NSString* userId, NSString* message);
void PubNubSendObject(NSString* userId, NSDictionary<NSString*, id>* object);

NSString* PubNubChannelName(NSString* user1Id, NSString* user2Id);


#endif
