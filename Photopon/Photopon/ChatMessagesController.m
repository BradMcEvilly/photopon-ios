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
#import "ChatPhotoponTableViewCell.h"
#import "ChatBasePresentableModel.h"
#import "ChatUserPresentableModel.h"
#import "ChatMessagePresentableModel.h"
#import "ChatPhotoponPresentableModel.h"
#import "PhotoponViewController.h"

#import "ChatMessageUserCell.h"
#import "ChatMessageFriendCell.h"
#import "CouponTableViewCell.h"

#import <UIImageView+WebCache.h>
#import "UIColor+Convinience.h"
#import <MBProgressHUD.h>

@interface ChatMessagesController ()

@property (nonatomic, copy) NSString *channelName;
@property (nonatomic, strong) PFUser *currentUser;
@property (nonatomic, strong) NSMutableArray *presentableModels;
@property (nonatomic, strong) NSMutableDictionary *resolvedUsers;
@property (nonatomic, strong) NSString* preEnteredMessage;

@property (nonatomic, strong) NSArray *allCoupons;

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

    self.allCoupons = GetNearbyCouponsPF();

    self.title = self.currentUser.username;
    
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

    self.chatTableView.rowHeight = UITableViewAutomaticDimension;
    self.chatTableView.estimatedRowHeight = 100;
    
    self.textField.text = _preEnteredMessage;
    _preEnteredMessage = @"";
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:@"#D94CCB" alpha:1.0];
}

- (void)configureTableView {
    self.chatTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.chatTableView.rowHeight = UITableViewAutomaticDimension;
    self.chatTableView.estimatedRowHeight = 20.0;

    [self registerCellWithClass:[ChatMessageFriendCell class]];
    [self registerCellWithClass:[ChatMessageUserCell class]];
    [self registerCellWithClass:[CouponTableViewCell class]];

    [self registerCellWithClass:[ChatMessageTableViewCell class]];
    [self registerCellWithClass:[ChatUserTableViewCell class]];
    [self registerCellWithClass:[ChatPhotoponTableViewCell class]];
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
    else if ([type isEqualToString:@"NOTIFICATION_MESSAGE"]) {
        return YES;
    }
    
    return NO;
}

- (void)addMessage:(NSDictionary*)message {
    if (![self canHandleMessage:message]) {
        return;
    }
    
    NSString *text = [message valueForKey:@"message"];
    NSString *userId = [message valueForKey:@"from"];
    NSString *type = message[@"type"];
    BOOL isCurrentUser = [userId isEqualToString:[[PFUser currentUser] objectId]];
    
    ChatBasePresentableModel *lastPresentableModel = [self.presentableModels lastObject];
    
    if (lastPresentableModel == nil || lastPresentableModel.currentUser != isCurrentUser) {
        ChatUserPresentableModel *userPresentableModel = [ChatUserPresentableModel new];
        userPresentableModel.currentUser = isCurrentUser;
        userPresentableModel.userName = [self getUserById:userId].username;
//        [self.presentableModels addObject:userPresentableModel];
        lastPresentableModel = userPresentableModel;
    }

    if ([type isEqualToString:@"MESSAGE"]) {
        if ([lastPresentableModel isKindOfClass:[ChatMessagePresentableModel class]]) {
            ChatMessagePresentableModel *messagePresentableModel = (ChatMessagePresentableModel *)lastPresentableModel;
            [messagePresentableModel appendMessage:text];
        } else {
            ChatMessagePresentableModel *messagePresentableModel = [ChatMessagePresentableModel new];
            messagePresentableModel.currentUser = isCurrentUser;
            messagePresentableModel.message = text;
            [self.presentableModels addObject:messagePresentableModel];
        }
    } else if ([type isEqualToString:@"NOTIFICATION_MESSAGE"]) {
        ChatPhotoponPresentableModel *photoponPresentableModel = [ChatPhotoponPresentableModel new];
        photoponPresentableModel.currentUser = isCurrentUser;
        photoponPresentableModel.couponTitle = message[@"couponTitle"];
        if ([message[@"subtype"] isEqualToString:@"PHOTOPON"]) {
            photoponPresentableModel.photoponStatus = @"New Photopon";
        } else {
            photoponPresentableModel.photoponStatus = @"Redeemed";
        }
        photoponPresentableModel.photoponId = message[@"photoponId"];
        [self.presentableModels addObject:photoponPresentableModel];
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
    
    __weak typeof(self) weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [pubnub historyForChannel:self.channelName start:nil end:nil limit:100 includeTimeToken:YES withCompletion:^(PNHistoryResult *result, PNErrorStatus *status) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (!status.isError) {
            [weakSelf didLoadMessages:result.data.messages];
        } else {
            // Error
        }
    }];
    
    
    [pubnub subscribeToChannels:@[self.channelName] withPresence:YES];
    [pubnub addListener:self];
}

- (void)setMessage:(NSString*)message {
    _preEnteredMessage = message;
}

- (void)didLoadMessages:(NSArray<NSDictionary *> *)messages
{
    for (NSDictionary *message in messages) {
        NSDictionary *messagePayload = message[@"message"];
        [self addMessage:messagePayload];
    }
    
    [self.chatTableView reloadData];
    if (self.presentableModels.count != 0) {
        [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.presentableModels.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
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

- (void)didSelectPhotopon:(ChatPhotoponPresentableModel *)photoponPresentableModel
{
    if (!photoponPresentableModel.isCurrentUser) {
        __weak typeof(self) weakSelf = self;
        [[PFQuery queryWithClassName:@"Photopon"] getObjectInBackgroundWithId:photoponPresentableModel.photoponId block:^(PFObject * _Nullable photopon, NSError * _Nullable error) {
            if (photopon) {
                PhotoponViewController* photoponView = (PhotoponViewController*)[weakSelf.storyboard instantiateViewControllerWithIdentifier:@"SBPhotoponView"];
                [photoponView setPhotopon:photopon];
                [weakSelf presentViewController:photoponView animated:YES completion:nil];
            }
        }];
    }
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
    id presentableModel = self.presentableModels[indexPath.row];
    
    if ([presentableModel isKindOfClass:[ChatMessagePresentableModel class]]) {
        if (((ChatMessagePresentableModel*)presentableModel).isCurrentUser) {
            ChatMessageUserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatMessageUserCell"];
            [cell updateWithPresentableModel:presentableModel];
            return cell;
        } else {
            ChatMessageFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatMessageFriendCell"];
            [cell updateWithPresentableModel:presentableModel];
            return cell;
        }
    }
    else if ([presentableModel isKindOfClass:[ChatUserPresentableModel class]]) {
        ChatUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ChatUserTableViewCell class]) forIndexPath:indexPath];
        [cell updateWithPresentableModel:presentableModel];
        return cell;
    }
    else if ([presentableModel isKindOfClass:[ChatPhotoponPresentableModel class]]) {
        presentableModel = (ChatPhotoponPresentableModel *)presentableModel;

        CouponTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CouponTableViewCell class])];
        //    NSDictionary *item = self.mockCoupons[indexPath.row];
        //#elif
        PFQuery *query = [PFQuery queryWithClassName:@"Photopon"];
        PFObject *photopon = [query getObjectWithId:((ChatPhotoponPresentableModel *)presentableModel).photoponId];

        PFObject *coupon = [photopon objectForKey:@"coupon"];
        PFObject *company = [coupon objectForKey:@"company"];
        PFFile *image = company[@"image"];
        cell.coupon = coupon;
        //#endif

        cell.title.text = [coupon objectForKey:@"title"];
        cell.longDescription.text = [coupon objectForKey:@"description"];

        NSDate* exp = [coupon objectForKey:@"expiration"];
        NSDate* now = [NSDate date];

        int numDays = DaysBetween(now, exp);

        NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
        [dateFormater setDateFormat:@"MM/dd/yyyy"];
        cell.expiration.text = [NSString stringWithFormat:@"Expires %@", [dateFormater stringFromDate:exp]];
        if (numDays > 2) {
            [cell.expiration setTextColor:[UIColor colorWithRed:0 green:0.4 blue:0 alpha:1]];
        } else if (numDays > 1) {
            [cell.expiration setTextColor:[UIColor colorWithRed:0.6 green:0.3 blue:0 alpha:1]];
        } else {
            [cell.expiration setTextColor:[UIColor colorWithRed:0.4 green:0 blue:0 alpha:1]];
        }

        [cell.thumbImage sd_setImageWithURL:[NSURL URLWithString:image.url] placeholderImage:[UIImage imageNamed:@"couponplaceholder.png"]];
        
        return cell;
    }
    
    return nil;
}


@end
