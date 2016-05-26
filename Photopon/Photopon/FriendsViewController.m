//
//  FriendsViewController.m
//  Photopon
//
//  Created by Hayk Hayotsyan on 12/8/15.
//  Copyright (c) 2015 Photopon. All rights reserved.
//
#import <SDWebImage/UIImageView+WebCache.h>

#import "FriendsViewController.h"
#import "FriendPopupViewController.h"
#import "ChatMessagesController.h"
#import "Parse/Parse.h"
#import "LogHelper.h"
#import "DBAccess.h"
#import "HeaderViewController.h"

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
    
    
    if (isSelectMode) {
//        UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(friendsSelected)];
//        self.navigationItem.rightBarButtonItem = anotherButton;
        HeaderViewController* header = [HeaderViewController addBackHeaderToView:self withTitle:@"Friends"];

        [header addRightButtonWithImage:@"Icon-Checked-User.png" withTarget:self action:@selector(friendsSelected)];
        [header setTheme:[UITheme yellowTheme]];
    } else {
        HeaderViewController* header = [HeaderViewController addHeaderToView:self withTitle:@"Friends"];

        [header addRightButtonWithImage:@"Icon-Add-User.png" withTarget:self action:@selector(addFriendClicked)];
        [header setTheme:[UITheme yellowTheme]];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnTableView:)];
    [self.friendsTable addGestureRecognizer:tap];


}

-(void)addFriendClicked {
    SendGAEvent(@"user_action", @"friends_view", @"add_firend_clickede");

    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    UIViewController *addFriend = [storyBoard instantiateViewControllerWithIdentifier:@"SBAddFriend"];
    [self presentViewController:addFriend animated:true completion:nil];

}


-(void)updateFriends {
    
    GetMyFriends(^(NSArray *results, NSError *error) {
        [myFriends removeAllObjects];
        for (PFObject* obj in results) {
            PFUser* object = (PFUser*)obj[@"user2"];
            
            if (object) {
                NSString* username = [object username];
                NSString* email = [object email];
                PFFile* img = [object valueForKey:@"image"];
                
                NSMutableDictionary* item = [@{
                                               @"friendshipId": [obj objectId],
                                               @"name": username,
                                               @"email": email,
                                               @"id": [object objectId],
                                               @"isSelected": @false,
                                               @"object": object
                                               } mutableCopy];
                
                if (img) {
                    item[@"image"] = img.url;
                }
                
                [myFriends addObject:item];
            } else {
                [myFriends addObject:@{
                                       @"friendshipId": [obj objectId],
                                       @"name": [obj valueForKey:@"name"],
                                       @"email": [obj valueForKey:@"phone"],
                                       @"id": [obj valueForKey:@"phoneId"],
                                       @"isSelected": @false,
                                       @"isPlaceholder": @true
                                       }];
            }
        }
        [self.friendsTable reloadData];
    });
    
    

}


-(void)viewWillAppear:(BOOL)animated {
    [self updateFriends];
    
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"CouponsScreen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];

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
        [self dismissViewControllerAnimated:YES completion:nil];
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
        cell.imageView.contentMode = UIViewContentModeScaleAspectFit;

    }

    
    NSDictionary *item = (NSDictionary *)[myFriends objectAtIndex:indexPath.row];
    cell.textLabel.text = [item objectForKey:@"name"];
    cell.detailTextLabel.text = [item objectForKey:@"email"];
    
    bool isSelected = [[item valueForKey:@"isSelected"] boolValue];
    
    if (isSelected && isSelectMode) {
        [cell.imageView setImage:[UIImage imageNamed:@"Icon-Yes.png"]];
    } else {
        NSString* img = [item objectForKey:@"image"];
        if (img) {
            [cell.imageView sd_setImageWithURL:[NSURL URLWithString:img] placeholderImage:[UIImage imageNamed:@"Icon-Administrator.png"]  options:SDWebImageAvoidAutoSetImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                
                dispatch_async(dispatch_get_main_queue(), ^{

                    [cell.imageView setImage:image];
                    
                    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
                    
                });
                
            }];
        } else {
            [cell.imageView setImage:[UIImage imageNamed:@"Icon-Administrator.png"]];

        }

        

    }
    
    return cell;
}




-(void) didTapOnTableView:(UIGestureRecognizer*) recognizer {
    CGPoint tapLocation = [recognizer locationInView:self.friendsTable];
    NSIndexPath *indexPath = [self.friendsTable indexPathForRowAtPoint:tapLocation];
    
    if (!indexPath) {
        return;
    }
    
    NSDictionary *item = (NSDictionary *)[myFriends objectAtIndex:indexPath.row];
    
    NSLog(@"%ld", (long)indexPath.row);
    
    if (isSelectMode) {
        
        bool selectedValue = [[item valueForKey:@"isSelected"] boolValue] == false;
        
        NSMutableDictionary* mutableDict = [item mutableCopy];
        [mutableDict setValue:[NSNumber numberWithBool:selectedValue] forKey:@"isSelected"];
        [myFriends setObject:mutableDict atIndexedSubscript:indexPath.row];
        
        [self.friendsTable reloadData];
        
        SendGAEvent(@"user_action", @"friends_view", @"friend_selected");
    } else {
        FriendPopupViewController* friendPopup = (FriendPopupViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"SBFriendPopup"];
        [friendPopup setFriend:item];
        [friendPopup setFriendViewController:self];
        
        friendPopup.providesPresentationContextTransitionStyle = YES;
        friendPopup.definesPresentationContext = YES;
        
        [friendPopup setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        [self presentViewController:friendPopup animated:YES completion:nil];
        
        SendGAEvent(@"user_action", @"friends_view", @"friend_tapped");
    }

}




@end













