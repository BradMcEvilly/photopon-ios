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
    BOOL isSelectMode;
    SEL onFriendSelected;
    id onFriendSelectedTarget;
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
                                   @"email": email,
                                   @"id": [object objectId],
                                   @"isSelected": @false
                                   }];
        }
        [self.friendsTable reloadData];
    });
    
    if (isSelectMode) {
        UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(friendsSelected)];
        self.navigationItem.rightBarButtonItem = anotherButton;
    }

}

-(void)friendsSelected {
    NSMutableArray *selectedUsers = [NSMutableArray array];
    
    for (int i = 0; i < [myFriends count]; i++) {
        NSDictionary *item = (NSDictionary *)[myFriends objectAtIndex:i];
        
        NSString* userId = [item objectForKey:@"id"];
        bool isSelected = [[item valueForKey:@"isSelected"] boolValue];
        
        if (isSelected) {
            [selectedUsers addObject:userId];
        }
        
    }
    
    if ([selectedUsers count] != 0) {
    
        [onFriendSelectedTarget performSelector:onFriendSelected withObject:selectedUsers];
    }
}

-(void)friendSelectedCallBack:(SEL)action target:(id)target {
    onFriendSelected = action;
    onFriendSelectedTarget = target;
    isSelectMode = true;
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FriendsCellIdentifier"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"FriendsCellIdentifier"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSDictionary *item = (NSDictionary *)[myFriends objectAtIndex:indexPath.row];
    cell.textLabel.text = [item objectForKey:@"name"];
    cell.detailTextLabel.text = [item objectForKey:@"email"];
    
    bool isSelected = [[item valueForKey:@"isSelected"] boolValue];
    
    if (isSelected && isSelectMode) {
        [cell.imageView setImage:[UIImage imageNamed:@"check.png"]];
    } else {
        [cell.imageView setImage:nil];
    }
   // NSString *path = [[NSBundle mainBundle] pathForResource:[item objectForKey:@"imageKey"] ofType:@"png"];
   // UIImage *theImage = [UIImage imageWithContentsOfFile:path];
   // cell.imageView.image = theImage;
    
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%ld", (long)indexPath.row);
    NSDictionary *item = (NSDictionary *)[myFriends objectAtIndex:indexPath.row];
    
    
    bool selectedValue = [[item valueForKey:@"isSelected"] boolValue] == false;

    
    NSMutableDictionary* mutableDict = [item mutableCopy];
    [mutableDict setValue:[NSNumber numberWithBool:selectedValue] forKey:@"isSelected"];
    [myFriends setObject:mutableDict atIndexedSubscript:indexPath.row];
    
    [self.friendsTable reloadData];
}




@end
