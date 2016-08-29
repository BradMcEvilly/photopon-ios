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
    
    HeaderViewController* header = [HeaderViewController addHeaderToView:self withTitle:@"Photopon"];
    [header setTheme:[UITheme redTheme]];

    
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
    
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnTableView:)];
    [self.notificationsTable addGestureRecognizer:tap];
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
        
        
        cell.imageView.image = [UIImage imageNamed:@"Icon-Add-User.png"];
        cell.imageView.transform = CGAffineTransformMakeScale(0.7, 0.7);

//        [[cell.imageView subviews] makeObjectsPerformSelector: @selector(removeFromSuperview)];
//        [cell.imageView addSubview:CreateFAImage(@"fa-user-plus", 24)];
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@ added you!", [assocUser username]];
        cell.detailTextLabel.text = @"You can add him back";
       
        SendGAEvent(@"user_action", @"notifications", @"firend_notification_clicked");
    } else if ([type isEqualToString:@"MESSAGE"]) {
        PFUser* assocUser = [item objectForKey:@"assocUser"];
        
        NSString* message = [item objectForKey:@"content"];
        
        cell.imageView.image = [UIImage imageNamed:@"Icon-Speach-Bubble.png"];
        cell.imageView.transform = CGAffineTransformMakeScale(0.7, 0.7);

//        [[cell.imageView subviews] makeObjectsPerformSelector: @selector(removeFromSuperview)];
//        [cell.imageView addSubview:CreateFAImage(@"fa-comments", 24)];
        
        cell.textLabel.text = message;
        
        NSDate *updated = [item updatedAt];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"EEE, MMM d, h:mm a"];
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Sent by %@ at %@", [assocUser username], [dateFormat stringFromDate:updated]];
        SendGAEvent(@"user_action", @"notifications", @"message_notification_clicked");
    } else if ([type isEqualToString:@"PHOTOPON"]) {
        PFUser* assocUser = [item objectForKey:@"assocUser"];
        
        PFObject* assocPhotopon = [item objectForKey:@"assocPhotopon"];
        
        cell.imageView.image = [UIImage imageNamed:@"Icon-Present.png"];
        
        //        [[cell.imageView subviews] makeObjectsPerformSelector: @selector(removeFromSuperview)];
        //        [cell.imageView addSubview:CreateFAImage(@"fa-gift", 24)];
        
        
        PFObject* coupon = [assocPhotopon objectForKey:@"coupon"];
        PFObject* company = [coupon objectForKey:@"company"];
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", [company objectForKey:@"name"], [coupon objectForKey:@"title"]];
        
        NSDate *updated = [item updatedAt];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"EEE, MMM d, h:mm a"];
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Sent by %@ at %@", [assocUser username], [dateFormat stringFromDate:updated]];
        SendGAEvent(@"user_action", @"notifications", @"photopon_notification_clicked");
        
    } else if ([type isEqualToString:@"ADDWALLET"]) {
        PFUser* assocUser = [item objectForKey:@"assocUser"];
        
        PFObject* assocPhotopon = [item objectForKey:@"assocPhotopon"];
        
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
        
        cell.imageView.image = [UIImage imageNamed:@"Icon-Pricing.png"];
        
        //        [[cell.imageView subviews] makeObjectsPerformSelector: @selector(removeFromSuperview)];
        //        [cell.imageView addSubview:CreateFAImage(@"fa-gift", 24)];
        
        
        PFObject* coupon = [assocPhotopon objectForKey:@"coupon"];
        PFObject* company = [coupon objectForKey:@"company"];
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@ redeemed your Photopon", [assocUser objectForKey:@"username"]];
        //cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", [company objectForKey:@"name"], [coupon objectForKey:@"title"]];
        
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@: %@", [company objectForKey:@"name"], [coupon objectForKey:@"title"]];
        
        SendGAEvent(@"user_action", @"notifications", @"redeemed_notification_clicked");
    } else if ([type isEqualToString:@"WELCOME_MESSAGE"]) {
        
        
        cell.imageView.image = [UIImage imageNamed:@"Icon-Photopon.png"];
        cell.textLabel.text = @"Welcome to Photopon!";
        cell.detailTextLabel.text = @"Swipe right to see nerby coupons.";
        SendGAEvent(@"user_action", @"notifications", @"welcome_message_clicked");
        
        
    } else if ([type isEqualToString:@"VERIFICATION_MESSAGE"]) {
        
        cell.imageView.image = [UIImage imageNamed:@"Icon-Phone.png"];
        cell.textLabel.text = @"Verify phone number";
        cell.detailTextLabel.text = @"Please click here to verify your phone number";
        SendGAEvent(@"user_action", @"notifications", @"verification_message_clicked");
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
    [self presentViewController:messageCtrl animated:YES completion:nil];
}

@end







