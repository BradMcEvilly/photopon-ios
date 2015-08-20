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

@implementation NotificationController
{
    NSMutableArray *allNotifications;
}


-(void)viewDidLoad
{
    [super viewDidLoad];
    [self.notificationsTable setDelegate:self];
    [self.notificationsTable setDataSource:self];
    allNotifications = [NSMutableArray array];
    
    GetNotifications(^(NSArray *results, NSError *error) {
        allNotifications = [NSMutableArray arrayWithArray:results];
        [self.notificationsTable reloadData];
    });
    
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MyIdentifier"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    PFObject *item = [allNotifications objectAtIndex:indexPath.row];
    NSString* type = [item objectForKey:@"type"];
    
    if ([type isEqualToString:@"FRIEND"]) {
        PFUser* assocUser = [item objectForKey:@"assocUser"];
        [assocUser fetchIfNeeded];
        
        
        cell.imageView.image = [UIImage imageNamed:@"empty20x20.png"];
        [cell.imageView addSubview:CreateFAImage(@"fa-user-plus", 24)];
        
        cell.textLabel.text = @"New Friend Request";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"User %@ have sent you friend request", [assocUser username]];
        
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeContactAdd];
        CGRect frame = CGRectMake(0.0, 0.0, 20, 20);
        button.frame = frame;
        
        [button addTarget:self action:@selector(checkButtonTapped:event:)  forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor = [UIColor clearColor];
        cell.accessoryView = button;


    } else if ([type isEqualToString:@"MESSAGE"]) {
        PFUser* assocUser = [item objectForKey:@"assocUser"];
        [assocUser fetchIfNeeded];
        
        NSString* message = [item objectForKey:@"content"];
        
        cell.imageView.image = [UIImage imageNamed:@"empty20x20.png"];
        [cell.imageView addSubview:CreateFAImage(@"fa-comments", 24)];
        
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
    LogDebug([NSString stringWithFormat:@"%ld", indexPath.row ]);
    
    PFObject *item = [allNotifications objectAtIndex:indexPath.row];

    NSString* type = [item objectForKey:@"type"];
    
    if ([type isEqualToString:@"FRIEND"]) {
        PFUser* assocUser = [item objectForKey:@"assocUser"];
        [assocUser fetchIfNeeded];
        
        PFObject *friendship = [PFObject objectWithClassName:@"Friends"];
        
        friendship[@"user1"] = [PFUser currentUser];
        friendship[@"user2"] = assocUser;
        
        [friendship saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [allNotifications removeObjectAtIndex:indexPath.row];
                [self.notificationsTable reloadData];
                [item delete];
                
                
            } else {
                //TODO: There was a problem, check error.description
            }
        }];
        
        
        
    } else if ([type isEqualToString:@"MESSAGE"]) {
        PFUser* assocUser = [item objectForKey:@"assocUser"];
        [assocUser fetchIfNeeded];
        
        ChatMessagesController* messageCtrl = (ChatMessagesController*)[self.storyboard instantiateViewControllerWithIdentifier:@"SBMessages"];
//        [self presentViewController:notificationCtrl animated:true completion:nil];
        [messageCtrl setUser:assocUser];
         
        [self.navigationController pushViewController:messageCtrl animated:true];

        
    } else if ([type isEqualToString:@"PHOTOPON"]) {
        
    }
    

    
}





@end
