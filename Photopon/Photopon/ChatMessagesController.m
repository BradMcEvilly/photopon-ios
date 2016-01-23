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
#import <PubNub/PubNub+History.h>
#import <PubNub/PNSubscriberResults.h>
#import <PubNub/PNHistoryResult.h>
#import <Parse/Parse.h>
#import <Parse/PFUser.h>
#import "DBAccess.h"
#import "ChatMessageTableViewCell.h"
#import "HeaderViewController.h"

@implementation ChatMessagesController
{
    PFUser *currentUser;
    NSMutableArray* currentMessages;
    NSMutableDictionary* resolvedUsers;

}


- (void)addMessage: (NSDictionary*)msg {
    NSString* message = [msg valueForKey:@"message"];
    NSString* from = [msg valueForKey:@"from"];
    
    if ([currentMessages count] == 0) {
        [currentMessages addObject:[@{
             @"messages": [@[message] mutableCopy],
             @"from": from
         } mutableCopy]];
    
    } else {
        NSString* lastFrom = [[currentMessages lastObject] valueForKey:@"from"];
        if (![lastFrom isEqualToString:from]) {
            [currentMessages addObject:[@{
                @"messages": [@[message] mutableCopy],
                @"from": from
            } mutableCopy]];

        } else {
            [[[currentMessages lastObject] valueForKey:@"messages"] addObject:message];
        }
    }
}

- (void)client:(PubNub *)client didReceiveMessage:(PNMessageResult*)msg {
    
    NSDictionary* data = msg.data.message;
    
    if (![data[@"type"] isEqualToString:@"MESSAGE"]) {
        return;
    }
    
    [self addMessage:data];
    
    [self.chatMessages reloadData];
    [self.chatMessages scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:currentMessages.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

-(void) setUser:(PFUser*)user {
    currentUser = user;
    
    currentMessages = [[NSMutableArray alloc] init];
    
    PubNub* pubnub = GetPubNub();
    NSString* channel = PubNubChannelName([currentUser objectId], [[PFUser currentUser] objectId]);
    
    [pubnub historyForChannel:channel start:nil end:nil limit:100 includeTimeToken:YES withCompletion:^(PNHistoryResult *result, PNErrorStatus *status) {
        
        if (!status.isError) {
            
            for (int i = 0; i < [result.data.messages count]; ++i) {
                
                NSDictionary* dict = result.data.messages[i];
                NSDictionary* msg = dict[@"message"];
                [self addMessage:msg];
                //[currentMessages addObject:msg];
            }
            
            [self.chatMessages reloadData];
            
            if (result.data.messages.count != 0) {
                [self.chatMessages scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:currentMessages.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
        } else {
            // Error
        }
    }];
    
    
    [pubnub subscribeToChannels:@[channel] withPresence:true];
    [pubnub addListener:self];
}

- (void) onSendClick {
    if ([self.textField.text length] != 0) {
        PubNubSendMessage([currentUser objectId], self.textField.text);
        CreateMessageNotification(currentUser, self.textField.text);
        self.textField.text = @"";
        
    }
}


-(void)viewWillAppear:(BOOL)animated {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"ChatMessagesScreen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}




- (void)viewDidLoad {
    [super viewDidLoad];
    
    resolvedUsers = [NSMutableDictionary dictionary];
    
    
    [HeaderViewController addBackHeaderToView:self withTitle:[currentUser username]];
    
    self.chatMessages.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.chatMessages setDelegate:self];
    [self.chatMessages setDataSource:self];
    
     
    [self.sendButton addTarget:self action:@selector(onSendClick) forControlEvents:UIControlEventTouchUpInside];
    
    
    /*
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                                object:nil];
     */
}

- (void)keyboardDidShow:(NSNotification *)notification
{
    // Get the size of the keyboard.
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGRect newTableFrame = self.mainView.frame;
    
    newTableFrame.size.height -= keyboardSize.height;
    newTableFrame.origin.y += keyboardSize.height;

    [self.mainView setFrame: newTableFrame];
    [self.chatMessages setContentOffset:CGPointMake(0, self.chatMessages.contentOffset.y + keyboardSize.height)];

}

- (void)keyboardWillHide:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGRect newTableFrame = self.mainView.frame;
    
    newTableFrame.size.height += keyboardSize.height;
    newTableFrame.origin.y -= keyboardSize.height;
    
    [self.mainView setFrame: newTableFrame];
    [self.chatMessages setContentOffset:CGPointMake(0, self.chatMessages.contentOffset.y - keyboardSize.height)];

}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [currentMessages count];
}













- (void)setUpCell:(ChatMessageTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *item = (NSDictionary *)[currentMessages objectAtIndex:indexPath.row];
    NSArray* messages = [item valueForKey:@"messages"];
    NSString* from = [item valueForKey:@"from"];
    
    if (![resolvedUsers objectForKey:from]) {
        PFUser* userFrom = [PFQuery getUserObjectWithId:from];
        [resolvedUsers setObject:userFrom forKey:from];
    }
    
    
    PFUser* userFrom = [resolvedUsers objectForKey: from];
    [cell setupCellWithUser:userFrom withMessages:messages];
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static ChatMessageTableViewCell *cell = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ChatMessageTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    });
    
    [self setUpCell:cell atIndexPath:indexPath];
    return [self calculateHeightForConfiguredSizingCell:cell];
}



- (CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell {
    [sizingCell layoutIfNeeded];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingExpandedSize];
    return size.height + 5;
}




- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatMessageTableViewCell *cell = (ChatMessageTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"ChatMessageTableViewCell"];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ChatMessageTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

    }
    
    [self setUpCell:cell atIndexPath:indexPath];
    
    return cell;
}



@end
