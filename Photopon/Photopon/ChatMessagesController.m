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

@interface ChatMessagesController ()
@property (nonatomic, copy) NSString *channelName;
@property (nonatomic, strong) PFUser *currentUser;
@property (nonatomic, strong) NSMutableArray* currentMessages;
@property (nonatomic, strong) NSMutableDictionary* resolvedUsers;
@end

@implementation ChatMessagesController

- (void)dealloc
{
    PubNub *pubNub = GetPubNub();
    [pubNub unsubscribeFromChannels:@[self.channelName] withPresence:YES];
}

- (void)addMessage: (NSDictionary*)msg {
    if (![msg[@"type"] isEqualToString:@"MESSAGE"]) {
        return;
    }
    
    NSString* message = [msg valueForKey:@"message"];
    NSString* from = [msg valueForKey:@"from"];
    
    if ([self.currentMessages count] == 0) {
        [self.currentMessages addObject:[@{
             @"messages": [@[message] mutableCopy],
             @"from": from
         } mutableCopy]];
    
    } else {
        NSString* lastFrom = [[self.currentMessages lastObject] valueForKey:@"from"];
        if (![lastFrom isEqualToString:from]) {
            [self.currentMessages addObject:[@{
                @"messages": [@[message] mutableCopy],
                @"from": from
            } mutableCopy]];

        } else {
            [[[self.currentMessages lastObject] valueForKey:@"messages"] addObject:message];
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
    [self.chatMessages scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentMessages.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)setUser:(PFUser*)user {
    self.currentUser = user;
    
    self.currentMessages = [[NSMutableArray alloc] init];
    
    PubNub* pubnub = GetPubNub();
    self.channelName = PubNubChannelName([self.currentUser objectId], [[PFUser currentUser] objectId]);
    
    [pubnub historyForChannel:self.channelName start:nil end:nil limit:100 includeTimeToken:YES withCompletion:^(PNHistoryResult *result, PNErrorStatus *status) {
        
        if (!status.isError) {
            
            for (int i = 0; i < [result.data.messages count]; ++i) {
                
                NSDictionary* dict = result.data.messages[i];
                NSDictionary* msg = dict[@"message"];
                [self addMessage:msg];
            }
            
            [self.chatMessages reloadData];
            
            if (result.data.messages.count != 0) {
                [self.chatMessages scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentMessages.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
        } else {
            // Error
        }
    }];
    
    
    [pubnub subscribeToChannels:@[self.channelName] withPresence:YES];
    [pubnub addListener:self];
}

- (void) onSendClick {
    if ([self.textField.text length] != 0) {
        PubNubSendMessage([self.currentUser objectId], self.textField.text);
        CreateMessageNotification(self.currentUser, self.textField.text);
        self.textField.text = @"";
        SendGAEvent(@"user_action", @"chat", @"message_sent");

    }
}

-(void)viewWillAppear:(BOOL)animated {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"ChatMessagesScreen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    SendGAEvent(@"user_action", @"chat", @"chat_started");

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.resolvedUsers = [NSMutableDictionary dictionary];
    
    
    [HeaderViewController addBackHeaderToView:self withTitle:[self.currentUser username]];
    
    self.chatMessages.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.chatMessages setDelegate:self];
    [self.chatMessages setDataSource:self];
    
     
    [self.sendButton addTarget:self action:@selector(onSendClick) forControlEvents:UIControlEventTouchUpInside];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                                object:nil];
    

    
}

- (void)keyboardDidShow:(NSNotification *)notification
{
    // Get the size of the keyboard.
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    self.topConstraint.constant = keyboardSize.height +  [UIApplication sharedApplication].statusBarFrame.size.height;
    
    [UIView animateWithDuration:1
                     animations:^{
                         [self.view layoutIfNeeded];
                     }];
    
    CGPoint currentOffset = [self.chatMessages contentOffset];
    currentOffset.y = currentOffset.y + keyboardSize.height - 80;
    [self.chatMessages setContentOffset:currentOffset animated:YES];

}

- (void)keyboardWillHide:(NSNotification *)notification
{
    
    self.topConstraint.constant = 80;
    
    [UIView animateWithDuration:1
                     animations:^{
                         [self.view layoutIfNeeded];
                     }];
    [self.chatMessages setContentInset:UIEdgeInsetsMake(0,0,0,0)];

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.currentMessages count];
}

- (void)setUpCell:(ChatMessageTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *item = (NSDictionary *)[self.currentMessages objectAtIndex:indexPath.row];
    NSArray* messages = [item valueForKey:@"messages"];
    NSString* from = [item valueForKey:@"from"];
    
    if (![self.resolvedUsers objectForKey:from]) {
        PFUser* userFrom = [PFQuery getUserObjectWithId:from];
        [self.resolvedUsers setObject:userFrom forKey:from];
    }
    
    
    PFUser* userFrom = [self.resolvedUsers objectForKey: from];
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
