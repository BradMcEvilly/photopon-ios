//
//  PubNubWrapper.m
//  Photopon
//
//  Created by Hayk Hayotsyan on 18/8/15.
//  Copyright (c) 2015 Photopon. All rights reserved.
//
#import "PubNubWrapper.h"
#import <PubNub/PubNub+Core.h>
#import <PubNub/PNConfiguration.h>
#import <PubNub/PubNub+Publish.h>
#import <Parse/Parse.h>

PubNub* pubnub = NULL;


PubNub* GetPubNub() {
    if (pubnub == NULL) {
        PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"pub-c-b5034842-3fa2-4543-9d2c-b7b7717cf7fa" subscribeKey:@"sub-c-884eb334-45d8-11e5-a836-02ee2ddab7fe"];
        pubnub = [PubNub clientWithConfiguration:configuration];
    }
    return pubnub;
}

void SendMessage(NSString* userId, NSString* message) {
    PubNub* pubnub = GetPubNub();
    NSString* myId = [[PFUser currentUser] objectId];
    
    NSString* channel = [NSString stringWithFormat:@"%@_%@", userId, myId];
    
    if ([userId compare:myId] == NSOrderedAscending) {
        channel = [NSString stringWithFormat:@"%@_%@", myId, userId];
    }
    
    
    [pubnub publish:message toChannel:channel withCompletion:^(PNPublishStatus *status) {

        
    }];
}