//
//  NotificationController.m
//  Photopon
//
//  Created by Hayk Hayotsyan on 14/8/15.
//  Copyright (c) 2015 Photopon. All rights reserved.
//

#import "NotificationController.h"
#import "ChatMessagesController.h"
#import "PhotoponViewController.h"
#import "Parse/Parse.h"
#import "DBAccess.h"
#import "Helper.h"
#import "LogHelper.h"
#import "HeaderViewController.h"
#import "IndicatorViewController.h"

@implementation NotificationController
{
    NSMutableArray *allNotifications;
    UIRefreshControl* refreshControl;

}

-(void)updateNotifications {
    GetNotifications(^(NSArray *results, NSError *error) {
        allNotifications = [NSMutableArray arrayWithArray:results];
        [self.notificationsTable reloadData];
        [refreshControl endRefreshing];
    });
}


-(void)viewDidLoad
{
    [super viewDidLoad];
    
    HeaderViewController* header = [HeaderViewController addHeaderToView:self withTitle:@"Notifications"];
    [header setTheme:[UITheme greenTheme]];

    
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
        
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeContactAdd];
        CGRect frame = CGRectMake(0.0, 0.0, 20, 20);
        button.frame = frame;
        
        [button addTarget:self action:@selector(checkButtonTapped:event:)  forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor = [UIColor clearColor];
        cell.accessoryView = button;


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

        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        CGRect frame = CGRectMake(0.0, 0.0, 20, 20);
        button.frame = frame;
        
        [button addTarget:self action:@selector(checkButtonTapped:event:)  forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor = [UIColor clearColor];
        cell.accessoryView = button;

        
        
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
        
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        CGRect frame = CGRectMake(0.0, 0.0, 20, 20);
        button.frame = frame;
        
        [button addTarget:self action:@selector(checkButtonTapped:event:)  forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor = [UIColor clearColor];
        cell.accessoryView = button;
        
        
    }

    
    return cell;
}






- (void)checkButtonTapped:(id)sender event:(id)event
{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.notificationsTable];
    NSIndexPath *indexPath = [self.notificationsTable indexPathForRowAtPoint: currentTouchPosition];
    if (indexPath != nil)
    {
        [self tableView: self.notificationsTable accessoryButtonTappedForRowWithIndexPath: indexPath];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    PFObject *item = [allNotifications objectAtIndex:indexPath.row];
    NSString* type = [item objectForKey:@"type"];
    
    if ([type isEqualToString:@"FRIEND"]) {
        PFUser* assocUser = [item objectForKey:@"assocUser"];
        
        PFObject *friendship = [PFObject objectWithClassName:@"Friends"];
        
        friendship[@"user1"] = [PFUser currentUser];
        friendship[@"user2"] = assocUser;
        
        [friendship saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [allNotifications removeObjectAtIndex:indexPath.row];
                [self.notificationsTable reloadData];
            } else {
                //TODO: There was a problem, check error.description
            }
        }];
        
        
        [item deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            [self updateNotifications];
        }];
        
        
        
    } else if ([type isEqualToString:@"MESSAGE"]) {
        PFUser* assocUser = [item objectForKey:@"assocUser"];
        //[assocUser fetchIfNeeded];
        
        ChatMessagesController* messageCtrl = (ChatMessagesController*)[self.storyboard instantiateViewControllerWithIdentifier:@"SBMessages"];
        [messageCtrl setUser:assocUser];
        
        [item deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            [self updateNotifications];
        }];
        [self presentViewController:messageCtrl animated:YES completion:nil];

        
    } else if ([type isEqualToString:@"PHOTOPON"]) {
        PFObject* assocPhotopon = [item objectForKey:@"assocPhotopon"];
        
        PhotoponViewController* photoponView = (PhotoponViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"SBPhotoponView"];
        [photoponView setPhotopon:assocPhotopon];
        
        [item deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            [self updateNotifications];
        }];
        [self presentViewController:photoponView animated:YES completion:nil];
    }
    

    
}





@end
