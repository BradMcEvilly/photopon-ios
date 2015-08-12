//
//  FriendsViewController.m
//  Photopon
//
//  Created by Hayk Hayotsyan on 12/8/15.
//  Copyright (c) 2015 Photopon. All rights reserved.
//

#import "FriendsViewController.h"
#import "Parse/Parse.h"
#import "LogHelper.h"

@implementation FriendsViewController
{
    NSMutableArray *myFriends;
}



-(void)viewDidLoad
{
    [super viewDidLoad];
    [self.friendsTable setDelegate:self];
    [self.friendsTable setDataSource:self];
    myFriends = [NSMutableArray array];
    
    PFUser* userId = [PFUser currentUser];
    
    PFQuery *query1 = [PFQuery queryWithClassName:@"Friends"];
    [query1 whereKey:@"user1" equalTo:userId];
    
    PFQuery *query2 = [PFQuery queryWithClassName:@"Friends"];
    [query2 whereKey:@"user2" equalTo:userId];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:@[query1,query2]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        for (PFObject* object in results) {
            PFUser* user1 = [object valueForKey:@"user1"];
            PFUser* user2 = [object valueForKey:@"user2"];
            
            PFUser* otherUser = [PFUser currentUser] == user1 ? user2 : user1;
            PFUser* otherUserFull = [PFQuery getUserObjectWithId:[otherUser objectId]];
            
            NSString* username = [otherUserFull username];
            NSString* email = [otherUserFull email];

            [myFriends addObject:@{
                                   @"name": username,
                                   @"email": email
                                   }];
        }
        [self.friendsTable reloadData];
    }];

}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [myFriends count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MyIdentifier"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSDictionary *item = (NSDictionary *)[myFriends objectAtIndex:indexPath.row];
    cell.textLabel.text = [item objectForKey:@"name"];
    cell.detailTextLabel.text = [item objectForKey:@"email"];
   // NSString *path = [[NSBundle mainBundle] pathForResource:[item objectForKey:@"imageKey"] ofType:@"png"];
   // UIImage *theImage = [UIImage imageWithContentsOfFile:path];
   // cell.imageView.image = theImage;
    
    return cell;
}

@end
