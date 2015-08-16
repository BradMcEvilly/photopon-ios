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
#import "DBAccess.h"

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
    
    GetMyFriends(^(NSArray *results, NSError *error) {
        for (PFUser* object in results) {
            
            NSString* username = [object username];
            NSString* email = [object email];

            [myFriends addObject:@{
                                   @"name": username,
                                   @"email": email
                                   }];
        }
        [self.friendsTable reloadData];
    });

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
