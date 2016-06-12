//
//  chatTableViewController.m
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
#import "HeaderViewController.h"
#import "ChatMessageTableViewCell.h"
#import "ChatUserTableViewCell.h"
#import "ChatBasePresentableModel.h"
#import "ChatUserPresentableModel.h"
#import "ChatMessagePresentableModel.h"

@interface ChatMessagesController ()
@property (nonatomic, copy) NSString *channelName;
@property (nonatomic, strong) PFUser *currentUser;
@property (nonatomic, strong) NSMutableArray *presentableModels;
@property (nonatomic, strong) NSMutableDictionary *resolvedUsers;
@end

@implementation ChatMessagesController

- (void)dealloc
{
    PubNub *pubNub = GetPubNub();
    [pubNub unsubscribeFromChannels:@[self.channelName] withPresence:YES];
}

#pragma mark - View Lifecycle

-(void)viewWillAppear:(BOOL)animated {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"chatTableViewScreen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    SendGAEvent(@"user_action", @"chat", @"chat_started");
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [HeaderViewController addBackHeaderToView:self withTitle:[self.currentUser username]];
    
    [self configureTableView];
    
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

- (void)configureTableView {
    self.chatTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.chatTableView.rowHeight = UITableViewAutomaticDimension;
    self.chatTableView.estimatedRowHeight = 20.0;
    [self registerCellWithClass:[ChatMessageTableViewCell class]];
    [self registerCellWithClass:[ChatUserTableViewCell class]];
}

- (void)registerCellWithClass:(Class)class
{
    UINib *nib = [UINib nibWithNibName:NSStringFromClass(class) bundle:nil];
    [self.chatTableView registerNib:nib forCellReuseIdentifier:NSStringFromClass(class)];
}

- (void)keyboardDidShow:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    self.topConstraint.constant = keyboardSize.height +  [UIApplication sharedApplication].statusBarFrame.size.height;
    
    [UIView animateWithDuration:1
                     animations:^{
                         [self.view layoutIfNeeded];
                     }];
    
    CGPoint currentOffset = [self.chatTableView contentOffset];
    currentOffset.y = currentOffset.y + keyboardSize.height - 80;
    [self.chatTableView setContentOffset:currentOffset animated:YES];
    
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    self.topConstraint.constant = 80;
    
    [UIView animateWithDuration:1
                     animations:^{
                         [self.view layoutIfNeeded];
                     }];
    [self.chatTableView setContentInset:UIEdgeInsetsMake(0,0,0,0)];
    
}

#pragma mark - Actions

- (void)onSendClick {
    if ([self.textField.text length] != 0) {
        PubNubSendMessage([self.currentUser objectId], self.textField.text);
        CreateMessageNotification(self.currentUser, self.textField.text);
        self.textField.text = @"";
        SendGAEvent(@"user_action", @"chat", @"message_sent");
        
    }
}

#pragma mark - Data Management

- (BOOL)canHandleMessage:(NSDictionary *)message {
    NSString *type = message[@"type"];
    
    if ([type isEqualToString:@"MESSAGE"]) {
        return YES;
    }
    
    return NO;
}

- (void)addMessage:(NSDictionary*)msg {
    if (![self canHandleMessage:msg]) {
        return;
    }
    
    NSString *text = [msg valueForKey:@"message"];
    NSString *userId = [msg valueForKey:@"from"];
    BOOL isCurrentUser = [userId isEqualToString:[[PFUser currentUser] objectId]];
    
    ChatBasePresentableModel *lastPresentableModel = [self.presentableModels lastObject];
    
    if (lastPresentableModel == nil || lastPresentableModel.currentUser != isCurrentUser) {
        ChatUserPresentableModel *userPresentableModel = [ChatUserPresentableModel new];
        userPresentableModel.currentUser = isCurrentUser;
        userPresentableModel.userName = [self getUserById:userId].username;
        [self.presentableModels addObject:userPresentableModel];
        
        ChatMessagePresentableModel *messagePresentableModel = [ChatMessagePresentableModel new];
        messagePresentableModel.currentUser = isCurrentUser;
        messagePresentableModel.message = text;
        [self.presentableModels addObject:messagePresentableModel];
    }
    else {
        if ([lastPresentableModel isKindOfClass:[ChatMessagePresentableModel class]]) {
            ChatMessagePresentableModel *messagePresentableModel = (ChatMessagePresentableModel *)lastPresentableModel;
            [messagePresentableModel appendMessage:text];
        }
    }
}

- (void)client:(PubNub *)client didReceiveMessage:(PNMessageResult*)msg {
    NSDictionary* message = msg.data.message;
    
    if (![self canHandleMessage:message]) {
        return;
    }
    
    [self addMessage:message];
    
    [self.chatTableView reloadData];
    [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.presentableModels.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)setUser:(PFUser*)user {
    self.currentUser = user;
    self.resolvedUsers = [@{self.currentUser.objectId: self.currentUser,
                            [[PFUser currentUser] objectId]: [PFUser currentUser]} mutableCopy];
    
    self.presentableModels = [[NSMutableArray alloc] init];
    
    PubNub* pubnub = GetPubNub();
    self.channelName = PubNubChannelName([self.currentUser objectId], [[PFUser currentUser] objectId]);
    
    [pubnub historyForChannel:self.channelName start:nil end:nil limit:100 includeTimeToken:YES withCompletion:^(PNHistoryResult *result, PNErrorStatus *status) {
        
        if (!status.isError) {
            for (NSDictionary *message in result.data.messages) {
                [self addMessage:message[@"message"]];
            }
            
            [self.chatTableView reloadData];
            
            if (self.presentableModels.count != 0) {
                [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.presentableModels.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
        } else {
            // Error
        }
    }];
    
    
    [pubnub subscribeToChannels:@[self.channelName] withPresence:YES];
    [pubnub addListener:self];
}

- (PFUser *)getUserById:(NSString *)userId
{
    PFUser *user = self.resolvedUsers[userId];
    if (!user) {
        user = [PFQuery getUserObjectWithId:userId];
        [self.resolvedUsers setObject:user forKey:userId];
    }
    
    return user;
}

#pragma mark - TableView DataSource/Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.presentableModels count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id cell = nil;
    id presentableModel = self.presentableModels[indexPath.row];
    
    if ([presentableModel isKindOfClass:[ChatMessagePresentableModel class]]) {
        cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ChatMessageTableViewCell class]) forIndexPath:indexPath];
        [cell updateWithPresentableModel:presentableModel];
    }
    else if ([presentableModel isKindOfClass:[ChatUserPresentableModel class]]) {
        cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ChatUserTableViewCell class]) forIndexPath:indexPath];
        [cell updateWithPresentableModel:presentableModel];
    }
    
    return cell;
}

@end
