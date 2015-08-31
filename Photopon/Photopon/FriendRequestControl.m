//
//  FriendRequestControl.m
//  Photopon
//
//  Created by Hayk Hayotsyan on 12/8/15.
//  Copyright (c) 2015 Photopon. All rights reserved.
//

#import "FriendRequestControl.h"
#import "Parse/Parse.h"
#import "LogHelper.h"
#import "FontAwesome/FAImageView.h"

@implementation FriendRequestControl
{
    NSMutableArray *myFriendRequests;
}

-(void) loadData
{
    PFUser* userId = [PFUser currentUser];
    
    PFQuery *query = [PFQuery queryWithClassName:@"FriendRequests"];
    [query includeKey:@"from"];
    [query whereKey:@"to" equalTo:userId];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        for (PFObject* object in results) {
            PFUser* userObj = [object valueForKey:@"from"];
            
            PFObject* fromUser = userObj;
            
            NSString* username = [fromUser valueForKey:@"username"];
            NSString* email = [fromUser valueForKey:@"email"];
            
            [myFriendRequests addObject:@{
                                          @"name": [@"Friend Request from " stringByAppendingString:username],
                                          @"email": email,
                                          @"user": userObj,
                                          @"request": object
                                          }];
        }
        [self.requestTable reloadData];
        
        if ([myFriendRequests count] == 0) {
            self.requestTable.alpha = 0;
            self.noRequests.alpha = 1;
        } else {
            self.requestTable.alpha = 1;
            self.noRequests.alpha = 0;
        }
    }];

}

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self.requestTable setDelegate:self];
    [self.requestTable setDataSource:self];
    myFriendRequests = [NSMutableArray array];
    
    [self loadData];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [myFriendRequests count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MyIdentifier"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeContactAdd];
        CGRect frame = CGRectMake(0.0, 0.0, 20, 20);
        button.frame = frame;
        
        [button addTarget:self action:@selector(checkButtonTapped:event:)  forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor = [UIColor clearColor];
        cell.accessoryView = button;

    }
    
    NSDictionary *item = (NSDictionary *)[myFriendRequests objectAtIndex:indexPath.row];
    cell.textLabel.text = [item objectForKey:@"name"];
    cell.detailTextLabel.text = [item objectForKey:@"email"];
    // NSString *path = [[NSBundle mainBundle] pathForResource:[item objectForKey:@"imageKey"] ofType:@"png"];
    // UIImage *theImage = [UIImage imageWithContentsOfFile:path];
    // cell.imageView.image = theImage;
    
    return cell;
}

- (void)checkButtonTapped:(id)sender event:(id)event
{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.requestTable];
    NSIndexPath *indexPath = [self.requestTable indexPathForRowAtPoint: currentTouchPosition];
    if (indexPath != nil)
    {
        [self tableView: self.requestTable accessoryButtonTappedForRowWithIndexPath: indexPath];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    LogDebug([NSString stringWithFormat:@"%ld", indexPath.row ]);
    
    NSMutableDictionary *item = [myFriendRequests objectAtIndex:indexPath.row];
    PFUser* fromUser = [item objectForKey:@"user"];
    PFUser* thisUser = [PFUser currentUser];
    PFObject* request = [item objectForKey:@"request"];
    
    PFObject *friendship = [PFObject objectWithClassName:@"Friends"];
    friendship[@"user1"] = fromUser;
    friendship[@"user2"] = thisUser;
    
    [friendship saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [request delete];
            [self loadData];
            [myFriendRequests removeObjectAtIndex:indexPath.row];
            [self.requestTable reloadData];
        } else {
            //TODO: There was a problem, check error.description
        }
    }];

    
}


@end
