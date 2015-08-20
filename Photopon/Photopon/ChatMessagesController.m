//
//  ChatMessagesController.m
//  Photopon
//
//  Created by Hayk Hayotsyan on 18/8/15.
//  Copyright (c) 2015 Photopon. All rights reserved.
//

#import "ChatMessagesController.h"
#import "PubNubWrapper.h"
#import <PubNub/PubNub+Subscribe.h>
#import <PubNub/PNSubscriberResults.h>
#import <Parse/Parse.h>
#import <Parse/PFUser.h>

#import "ChatMessageView.h"

@implementation ChatMessagesController
{
    PFUser* currentUser;
    int numMessages;
}


- (void)client:(PubNub *)client didReceiveMessage:(PNMessageResult*)msg {
    
    NSObject* data = msg.data.message;
    
    NSString* from = [data valueForKey:@"from"];
    NSString* to = [data valueForKey:@"to"];
    NSString* message = [data valueForKey:@"message"];
    
    PFUser* userFrom = [PFQuery getUserObjectWithId:from];
    PFUser* userTo = [PFQuery getUserObjectWithId:to];

    
    ChatMessageView *cell = [[ChatMessageView alloc] initWithFrame:CGRectMake(0.f, numMessages * 50, self.view.bounds.size.width, 50)];
    numMessages++;
    
    // customize the cell's appearance here
//        cell.leftImage.image = [UIImage imageNamed:@"leftImage.png"];
    cell.textLabel.text = message;
//        cell.rightImage.image = [UIImage imageNamed:@"rightImage.png"];
    
    if (userFrom == [PFUser currentUser]) {
        cell.textLabel.textAlignment = NSTextAlignmentRight;
    }
    
        
    [self.contentView addSubview:cell];
    
}

-(void) setUser:(PFUser*)user {
    currentUser = user;
    
    PubNub* pubnub = GetPubNub();
    NSString* channel = PubNubChannelName([currentUser objectId], [[PFUser currentUser] objectId]);
    
    [pubnub subscribeToChannels:@[channel] withPresence:true];
    [pubnub addListener:self];
}

- (void) onSendClick {
    if ([self.textField.text length] != 0) {
        PubNubSendMessage([currentUser objectId], self.textField.text);
        self.textField.text = @"";
        
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    numMessages = 0;
    
    self.contentView = [[UIView alloc] init];
    [self.scrollView addSubview:self.contentView];
    
    
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    
    id views = @{
                 @"scrollView": self.scrollView,
                 @"contentView": self.contentView
                 };
    
    // setup scrollview constraints
    //[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[scrollView]|" options:0 metrics:nil views:views]];
    //[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[scrollView]|" options:0 metrics:nil views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentView]|" options:0 metrics:nil views:views]];

    
    
    
    [self setTitle:[currentUser username]];
    
    [self.sendButton addTarget:self action:@selector(onSendClick) forControlEvents:UIControlEventTouchUpInside];
    //self.textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
}




@end
