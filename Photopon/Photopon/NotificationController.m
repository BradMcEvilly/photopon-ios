//
//  NotificationController.m
//  Photopon
//
//  Created by Hayk Hayotsyan on 14/8/15.
//  Copyright (c) 2015 Photopon. All rights reserved.
//

#import "NotificationController.h"
#import "ChatMessagesController.h"
#import "Parse/Parse.h"
#import "DBAccess.h"
#import "Helper.h"
#import "LogHelper.h"
#import "HeaderViewController.h"
#import "IndicatorViewController.h"
#import "AlertBox.h"
#import "BasicNotificationCell.h"
#import "UIViewController+Menu.h"
#import "SentCouponCell.h"
#import <UIImageView+WebCache.h>
#import "NSDate+Pretty.h"
#import "UIColor+Convinience.h"

@implementation NotificationController
{
    NSMutableArray *allNotifications;
    UIRefreshControl* refreshControl;

}

-(void)updateNotifications {
    
    if ([PFUser currentUser]) {    
        SendGAEvent(@"user_action", @"notifications", @"manual_update");
        GetNotifications(^(NSArray *results, NSError *error) {
            allNotifications = [NSMutableArray arrayWithArray:results];
            [self.notificationsTable reloadData];
            [refreshControl endRefreshing];
        });
    } else {
        [allNotifications removeAllObjects];
        [allNotifications addObject:@{ @"type": @"WELCOME_MESSAGE" }];
        [allNotifications addObject:@{ @"type": @"VERIFICATION_MESSAGE" }];
    }
    
}


-(void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [self.notificationsTable setDelegate:self];
    [self.notificationsTable setDataSource:self];
    allNotifications = [NSMutableArray array];
    
    
    [self updateNotifications];
    
    [RealTimeNotificationHandler addListener:@"NOTIFICATION.NOTIFICATIONVIEW" withBlock:^(NSString *notificationType) {
        [self updateNotifications];
    }];
    
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.backgroundColor = [UIColor whiteColor];
    refreshControl.tintColor = [UIColor blackColor];
    [refreshControl addTarget:self
                       action:@selector(updateNotifications)
             forControlEvents:UIControlEventValueChanged];
    
    
    UITableViewController *tableViewController = [[UITableViewController alloc] init];
    tableViewController.tableView = self.notificationsTable;
    tableViewController.refreshControl = refreshControl;
    self.notificationsTable.rowHeight = UITableViewAutomaticDimension;
    self.notificationsTable.estimatedRowHeight = 120;

    [self.notificationsTable registerNib:[UINib nibWithNibName:@"BasicNotificationCell" bundle:nil] forCellReuseIdentifier:@"BasicNotificationCell"];
    [self.notificationsTable registerNib:[UINib nibWithNibName:@"SentCouponCell" bundle:nil] forCellReuseIdentifier:@"SentCouponCell"];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnTableView:)];
    [self.notificationsTable addGestureRecognizer:tap];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"menu-icon"] style:UIBarButtonItemStylePlain target:self action:@selector(leftMenuClicked)];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:@"#F26161" alpha:1.0];
}

-(void)viewWillAppear:(BOOL)animated {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"NotificationsScreen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}



-(void)dealloc {
    [RealTimeNotificationHandler removeListener:@"NOTIFICATION.NOTIFICATIONVIEW"];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [allNotifications count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NotificationsCellIdentifier"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"NotificationsCellIdentifier"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    PFObject *item = [allNotifications objectAtIndex:indexPath.row];
    NSString* type = [item objectForKey:@"type"];
    
    if ([type isEqualToString:@"FRIEND"]) {
        PFUser* assocUser = [item objectForKey:@"assocUser"];
        PFFile *image = assocUser[@"image"];

        BasicNotificationCell *notifCell = [self.notificationsTable dequeueReusableCellWithIdentifier:@"BasicNotificationCell"];

        if (image) {
            [notifCell.notificationImageView sd_setImageWithURL:[NSURL URLWithString:image.url] placeholderImage:[UIImage imageNamed:@"profileplaceholder"]];
        }
        notifCell.user = assocUser[@"username"];
        notifCell.subtitleLabel.text = @"You can add him back";
        [notifCell setupCell];
        //SendGAEvent(@"user_action", @"notifications", @"verification_message_clicked");
        return notifCell;
        SendGAEvent(@"user_action", @"notifications", @"firend_notification_clicked");
    } else if ([type isEqualToString:@"MESSAGE"]) {
        PFUser* assocUser = [item objectForKey:@"assocUser"];
        PFFile *image = assocUser[@"image"];
        BasicNotificationCell *notifCell = [self.notificationsTable dequeueReusableCellWithIdentifier:@"BasicNotificationCell"];

        if (image) {
            [notifCell.notificationImageView sd_setImageWithURL:[NSURL URLWithString:image.url] placeholderImage:[UIImage imageNamed:@"profileplaceholder"]];
        }
        notifCell.user = assocUser[@"username"];
        notifCell.templateType = BasicNotificationCellTemplateMessagedYou;
        [notifCell setupCell];
        //SendGAEvent(@"user_action", @"notifications", @"verification_message_clicked");
        return notifCell;

        cell.imageView.image = [UIImage imageNamed:@"Icon-Speach-Bubble.png"];
        cell.imageView.transform = CGAffineTransformMakeScale(0.7, 0.7);

//        [[cell.imageView subviews] makeObjectsPerformSelector: @selector(removeFromSuperview)];
//        [cell.imageView addSubview:CreateFAImage(@"fa-comments", 24)];
        
        NSDate *updated = [item updatedAt];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"EEE, MMM d, h:mm a"];
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Sent by %@ at %@", [assocUser username], [dateFormat stringFromDate:updated]];
        SendGAEvent(@"user_action", @"notifications", @"message_notification_clicked");
    } else if ([type isEqualToString:@"PHOTOPON"]) {
        SentCouponCell *couponCell = [tableView dequeueReusableCellWithIdentifier:@"SentCouponCell"];

        PFUser* assocUser = [item objectForKey:@"assocUser"];
        PFObject* assocPhotopon = [item objectForKey:@"assocPhotopon"];
        
        //        [[cell.imageView subviews] makeObjectsPerformSelector: @selector(removeFromSuperview)];
        //        [cell.imageView addSubview:CreateFAImage(@"fa-gift", 24)];
        
        
        PFObject* coupon = [assocPhotopon objectForKey:@"coupon"];
        PFObject* company = [coupon objectForKey:@"company"];
        PFFile *couponImage = [company objectForKey:@"image"];
        PFFile *avatarImage = assocUser[@"image"];

        [couponCell.couponImageView sd_setImageWithURL:[NSURL URLWithString:couponImage.url] placeholderImage:[UIImage imageNamed:@"Icon-Present.png"]];

        if (avatarImage) {
            [couponCell.avatarImageView sd_setImageWithURL:[NSURL URLWithString:avatarImage.url] placeholderImage:[UIImage imageNamed:@"profileplaceholder"]];
        }
        NSDate *expiration = coupon[@"expiration"];
        couponCell.couponExpiryLabel.text = [expiration prettyString];
        couponCell.couponTitleLabel.text = coupon[@"title"];
        couponCell.couponSubtitleLabel.text = coupon[@"description"];
        couponCell.titleLabel.text = assocUser[@"username"];
        return couponCell;

        cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", [company objectForKey:@"name"], [coupon objectForKey:@"title"]];
        
        NSDate *updated = [item updatedAt];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"EEE, MMM d, h:mm a"];
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Sent by %@ at %@", [assocUser username], [dateFormat stringFromDate:updated]];
        SendGAEvent(@"user_action", @"notifications", @"photopon_notification_clicked");
        
    } else if ([type isEqualToString:@"ADDWALLET"]) {
        PFUser* assocUser = [item objectForKey:@"assocUser"];
        
        PFObject* assocPhotopon = [item objectForKey:@"assocPhotopon"];
        PFFile *image = assocUser[@"image"];

        BasicNotificationCell *notifCell = [self.notificationsTable dequeueReusableCellWithIdentifier:@"BasicNotificationCell"];

        if (image) {
            [notifCell.notificationImageView sd_setImageWithURL:[NSURL URLWithString:image.url] placeholderImage:[UIImage imageNamed:@"profileplaceholder"]];
        }
        notifCell.user = assocUser[@"username"];
        notifCell.templateType = BasicNotificationCellTemplateSavedYourPhotopon;
        [notifCell setupCell];
        //SendGAEvent(@"user_action", @"notifications", @"verification_message_clicked");
        return notifCell;

        cell.imageView.image = [UIImage imageNamed:@"Icon-Wallet-22.png"];
        
        //        [[cell.imageView subviews] makeObjectsPerformSelector: @selector(removeFromSuperview)];
        //        [cell.imageView addSubview:CreateFAImage(@"fa-gift", 24)];
        
        
        PFObject* coupon = [assocPhotopon objectForKey:@"coupon"];
        PFObject* company = [coupon objectForKey:@"company"];
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@ saved your Photopon", [assocUser objectForKey:@"username"]];
        //cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", [company objectForKey:@"name"], [coupon objectForKey:@"title"]];
        
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@: %@", [company objectForKey:@"name"], [coupon objectForKey:@"title"]];
        
        SendGAEvent(@"user_action", @"notifications", @"walletadd_notification_clicked");
    }else if ([type isEqualToString:@"REDEEMED"]) {
        
        PFUser* assocUser = [item objectForKey:@"assocUser"];
        
        PFObject* assocPhotopon = [item objectForKey:@"assocPhotopon"];
        PFFile *image = assocUser[@"image"];

        cell.imageView.image = [UIImage imageNamed:@"Icon-Pricing.png"];
        
        //        [[cell.imageView subviews] makeObjectsPerformSelector: @selector(removeFromSuperview)];
        //        [cell.imageView addSubview:CreateFAImage(@"fa-gift", 24)];
        
        
        PFObject* coupon = [assocPhotopon objectForKey:@"coupon"];
        PFObject* company = [coupon objectForKey:@"company"];

        BasicNotificationCell *notifCell = [self.notificationsTable dequeueReusableCellWithIdentifier:@"BasicNotificationCell"];

        if (image) {
            [notifCell.notificationImageView sd_setImageWithURL:[NSURL URLWithString:image.url] placeholderImage:[UIImage imageNamed:@"profileplaceholder"]];
        }
        notifCell.user = assocUser[@"username"];
        notifCell.templateType = BasicNotificationCellTemplateRedeemed;
        [notifCell setupCell];
        //SendGAEvent(@"user_action", @"notifications", @"verification_message_clicked");
        return notifCell;

        cell.textLabel.text = [NSString stringWithFormat:@"%@ redeemed your Photopon", [assocUser objectForKey:@"username"]];
        //cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", [company objectForKey:@"name"], [coupon objectForKey:@"title"]];
        
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@: %@", [company objectForKey:@"name"], [coupon objectForKey:@"title"]];
        
        SendGAEvent(@"user_action", @"notifications", @"redeemed_notification_clicked");
    } else if ([type isEqualToString:@"WELCOME_MESSAGE"]) {
        BasicNotificationCell *notifCell = [self.notificationsTable dequeueReusableCellWithIdentifier:@"BasicNotificationCell"];

        notifCell.notificationImageView.image = [UIImage imageNamed:@"Icon-Photopon.png"];
        notifCell.titleLabel.text = @"Welcome to Photopon!";
        notifCell.subtitleLabel.text = @"Swipe right to see nerby coupons.";
        //SendGAEvent(@"user_action", @"notifications", @"verification_message_clicked");
        return notifCell;
        
        
    } else if ([type isEqualToString:@"VERIFICATION_MESSAGE"]) {
        BasicNotificationCell *notifCell = [self.notificationsTable dequeueReusableCellWithIdentifier:@"BasicNotificationCell"];

        notifCell.notificationImageView.image = [UIImage imageNamed:@"Icon-Phone.png"];
        notifCell.titleLabel.text = @"Verify phone number";
        notifCell.subtitleLabel.text = @"Please click here to verify your phone number";
        //SendGAEvent(@"user_action", @"notifications", @"verification_message_clicked");
        return notifCell;
    }

    
    return cell;
}



- (UIViewController*) topMostController {
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}


- (void)didTapOnTableView:(UIGestureRecognizer*) recognizer {
    CGPoint tapLocation = [recognizer locationInView:self.notificationsTable];
    NSIndexPath *indexPath = [self.notificationsTable indexPathForRowAtPoint:tapLocation];
    
    if (!indexPath) {
        return;
    }
    
    PFObject *item = [allNotifications objectAtIndex:indexPath.row];
    
    NSString* type = [item objectForKey:@"type"];
    
    if ([type isEqualToString:@"FRIEND"]) {
        PFUser* assocUser = [item objectForKey:@"assocUser"];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *addAction = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Add %@", [assocUser username]] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            PFObject *friendship = [PFObject objectWithClassName:@"Friends"];
            
            friendship[@"user1"] = [PFUser currentUser];
            friendship[@"user2"] = assocUser;
            
            [friendship saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
            }];
            
            
            [item deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                [self updateNotifications];
            }];
        }];
        
        UIAlertAction *ignoreAction = [UIAlertAction actionWithTitle:@"Ignore" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [item deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                [self updateNotifications];
            }];
        }];
        
        
        [alert addAction:addAction];
        [alert addAction:ignoreAction];
        
        alert.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
        alert.popoverPresentationController.sourceView = self.notificationsTable;
        alert.popoverPresentationController.sourceRect = CGRectMake(20, 40, 10, 10);
        
        
        [self presentViewController:alert animated:YES completion:nil];
    } else if ([type isEqualToString:@"MESSAGE"]) {
        PFUser* assocUser = [item objectForKey:@"assocUser"];
        [self showChatWithUser:assocUser];
        [item deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            [self updateNotifications];
        }];
    } else if ([type isEqualToString:@"PHOTOPON"]) {
        PFUser* assocUser = [item objectForKey:@"assocUser"];
        [self showChatWithUser:assocUser];
    } else if ([type isEqualToString:@"ADDWALLET"]) {
        [item deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            [self updateNotifications];
        }];
    } else if ([type isEqualToString:@"REDEEMED"]) {
        
        [item deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            [self updateNotifications];
        }];
    } else if ([type isEqualToString:@"WELCOME_MESSAGE"]) {
        
        
        
    } else if ([type isEqualToString:@"VERIFICATION_MESSAGE"]) {
        SendGAEvent(@"user_action", @"welcome_message", @"set_number");
        UIViewController* mainCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"SBNumberVerification"];
        [[self topMostController] presentViewController:mainCtrl animated:true completion:nil];    
    }

    
    
    

}

- (void)showChatWithUser:(PFUser *)user {
    ChatMessagesController* messageCtrl = (ChatMessagesController*)[self.storyboard instantiateViewControllerWithIdentifier:@"SBMessages"];
    [messageCtrl setUser:user];
    [self.navigationController pushViewController:messageCtrl animated:YES];
}

@end







