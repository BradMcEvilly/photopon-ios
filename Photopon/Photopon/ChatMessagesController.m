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
    
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentView]|" options:0 metrics:nil views:views]];

    
    
    
    [self setTitle:[currentUser username]];
    
    [self.sendButton addTarget:self action:@selector(onSendClick) forControlEvents:UIControlEventTouchUpInside];
    [self registerForKeyboardNotifications];
    
    
    
}








// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    //UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    
    
    CGRect b = self.mainView.bounds;
    
    [self.mainView setBounds:CGRectMake(b.origin.x, b.origin.y + kbSize.height / 2, b.size.width, b.size.height - kbSize.height)];
    
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    //UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    //self.view.contentInset = contentInsets;
    //self.scrollView.scrollIndicatorInsets = contentInsets;
}


@end
