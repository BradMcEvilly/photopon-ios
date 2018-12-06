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
#import "AlertBox.h"
#import "TooltipFactory.h"
#import "FriendTableViewCell.h"
#import "UIViewController+Menu.h"
#import "UIColor+Convinience.h"
#import "UIColor+Theme.h"

@interface FriendsViewController()

@property (nonatomic, strong) AMPopTip *tooltip;
@property (nonatomic, weak) HeaderViewController *headerVC;
@property (nonatomic, strong) NSMutableArray *myFriendsPF;

@end

@implementation FriendsViewController
{
    NSMutableArray *myFriends;
    NSMutableArray *pendingFriends;
    NSMutableArray* excludedFriends;
    BOOL isSelectMode;
    SEL onFriendSelected;
    id onFriendSelectedTarget;
     UIRefreshControl* refreshControl;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.friendsTable.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    [self.friendsTable setDelegate:self];
    [self.friendsTable setDataSource:self];
    myFriends = [NSMutableArray array];
    pendingFriends = [NSMutableArray array];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"menu-icon"] style:UIBarButtonItemStylePlain target:self action:@selector(leftMenuClicked)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"add-friend-image"] style:UIBarButtonItemStylePlain target:self action:@selector(addFriendClicked)];

    [self.friendsTable registerNib:[UINib nibWithNibName:@"FriendTableViewCell" bundle:nil] forCellReuseIdentifier:@"FriendTableViewCell"];
    
    [self.btnAddFriend addTarget:self action:@selector(addFriendClicked) forControlEvents:UIControlEventTouchDown];
    
    
    
//    if (isSelectMode) {
////        UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(friendsSelected)];
////        self.navigationItem.rightBarButtonItem = anotherButton;
//        HeaderViewController* header = [HeaderViewController addBackHeaderToView:self withTitle:@"Friends"];
//
//        [header addRightButtonWithImage:@"Icon-Checked-User.png" withTarget:self action:@selector(friendsSelected)];
//        [header setTheme:[UITheme yellowTheme]];
//        self.headerVC = header;
//    } else {
//        HeaderViewController* header = [HeaderViewController addHeaderToView:self withTitle:@"Friends"];
//
//        [header addRightButtonWithImage:@"Icon-Add-User.png" withTarget:self action:@selector(addFriendClicked)];
//        [header setTheme:[UITheme yellowTheme]];
//        self.headerVC = header;
//    }

    
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.backgroundColor = [UIColor whiteColor];
    refreshControl.tintColor = [UIColor blackColor];
    [refreshControl addTarget:self
                       action:@selector(updateFriends)
             forControlEvents:UIControlEventValueChanged];
    
    
    UITableViewController *tableViewController = [[UITableViewController alloc] init];
    tableViewController.tableView = self.friendsTable;
    tableViewController.refreshControl = refreshControl;

}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor friendsThemeColor];
    if (!isSelectMode) {
        return;
    }

    if (!self.tooltip) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (!self.tooltip) {
                self.tooltip = [TooltipFactory showSharePhotoponForView:self.view frame:[self.headerVC.rightMenuButton.superview convertRect:self.headerVC.rightMenuButton.frame toView:self.view]];
            }
        });
    }

}

-(void)addFriendClicked {
    SendGAEvent(@"user_action", @"friends_view", @"add_firend_clickede");
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    UIViewController *addFriend = [storyBoard instantiateViewControllerWithIdentifier:@"SBAddFriend"];
    [self.navigationController pushViewController:addFriend animated:true];

}

-(void)excludeFriends:(NSArray*)toExclude {
    excludedFriends = [toExclude mutableCopy];
}

-(BOOL)isExcluded: (PFUser*)user {
    for (int i = 0; i < [excludedFriends count]; ++i) {
        PFObject* obj = excludedFriends[i];
        if ([obj.objectId isEqualToString:user.objectId]) {
            return TRUE;
        }
    }
    return FALSE;
}

-(void)updateFriends {
    [self.emptyView setHidden:YES];
    
    GetMyFriends(^(NSArray *results, NSError *error) {
        [myFriends removeAllObjects];
        [pendingFriends removeAllObjects];
        for (PFObject* obj in results) {
            PFUser* object = (PFUser*)obj[@"user2"];
            
            if (object) {
                if ([self isExcluded: object]) {
                    continue;
                }
                [myFriends addObject:object];
            }else{
                PFUser* object = [PFUser new];
                [object setUsername:[obj objectForKey:@"name"]];
                [object setEmail:[obj objectForKey:@"phone"]];
                [pendingFriends addObject:object];
            }
        }
        [self.emptyView setHidden:pendingFriends.count + myFriends.count > 0];
        
        [self.friendsTable reloadData];
        [refreshControl endRefreshing];
    });
}


-(void)viewWillAppear:(BOOL)animated {
    
    [self updateFriends];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"CouponsScreen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];

}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return (myFriends.count + pendingFriends.count >0) ? 2 : 0;
  
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0){
        return [myFriends count];
    }else{
        return [pendingFriends count];
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        
        PFObject *item = [myFriends objectAtIndex:indexPath.row];
        PFObject *user = [PFUser currentUser];
        NSString *friendID = item[@"objectId"];
        NSString *userID = user[@"objectId"];
        
        FriendTableViewCell *friendCell = [tableView dequeueReusableCellWithIdentifier:@"FriendTableViewCell"];
        [friendCell setName:item[@"email"] username:item[@"username"]];
        
        PFQuery *query = [PFQuery queryWithClassName:@"PerUserShare"];
        
        [query whereKey:@"user" equalTo:user];
        [query whereKey:@"friend" equalTo:item];
        [query countObjectsInBackgroundWithBlock:^(int number, NSError * _Nullable error) {
            int shared = number;
            PFQuery *query = [PFQuery queryWithClassName:@"Redeemed"];
            [query whereKey:@"from" equalTo:user];
            [query whereKey:@"to" equalTo:item];
            [query countObjectsInBackgroundWithBlock:^(int number, NSError * _Nullable error) {
                [friendCell setNumberOfGiftsUsed:number giftsShared:shared];
            }];
        }];
        
        
        PFFile* img = [item objectForKey:@"image"];
        if (img) {
            [friendCell.friendImageView sd_setImageWithURL:[NSURL URLWithString:img.url] placeholderImage:[UIImage imageNamed:@"profileplaceholder"]];
        }
        return friendCell;
        
    }else{
        
        PFObject *item =  [pendingFriends objectAtIndex:indexPath.row];
        PFObject *user = [PFUser currentUser];
        NSString *friendID = item[@"objectId"];
        NSString *userID = user[@"objectId"];
        
        FriendTableViewCell *friendCell = [tableView dequeueReusableCellWithIdentifier:@"FriendTableViewCell"];
        [friendCell setName:nil username:item[@"username"]];
        [friendCell.friendShareInfoLabel setText:item[@"email"]];
        return friendCell;
        
    }
   
}




-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        NSDictionary *item = (NSDictionary *)[myFriends objectAtIndex:indexPath.row];
        
        NSLog(@"%ld", (long)indexPath.row);
        
        if (isSelectMode) {
            
            bool selectedValue = [[item valueForKey:@"isSelected"] boolValue] == false;
            
            
            if (selectedValue) {
                int numSelected = 0;
                for (int i = 0; i < [myFriends count]; i++) {
                    NSDictionary *item = (NSDictionary *)[myFriends objectAtIndex:i];
                    bool isSelected = [[item valueForKey:@"isSelected"] boolValue];
                    
                    if (isSelected) {
                        numSelected++;
                    }
                }
                
                if (numSelected >= 10) {
                    [AlertBox showMessageFor:self withTitle:@"Share limit reached"
                                 withMessage:@"You can share a single Photopon with no more than 10 friends"
                                  leftButton:nil
                                 rightButton:@"OK"
                                  leftAction:nil
                                 rightAction:nil];
                    
                    return;
                    
                }
                
            }
            
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

    }/*else{
        
        NSDictionary *item = (NSDictionary *)[pendingFriends objectAtIndex:indexPath.row];
        
        NSLog(@"%ld", (long)indexPath.row);
        
        if (isSelectMode) {
            
            bool selectedValue = [[item valueForKey:@"isSelected"] boolValue] == false;
            
            
            if (selectedValue) {
                int numSelected = 0;
                for (int i = 0; i < [pendingFriends count]; i++) {
                    NSDictionary *item = (NSDictionary *)[pendingFriends objectAtIndex:i];
                    bool isSelected = [[item valueForKey:@"isSelected"] boolValue];
                    
                    if (isSelected) {
                        numSelected++;
                    }
                }
                
                if (numSelected >= 10) {
                    [AlertBox showMessageFor:self withTitle:@"Share limit reached"
                                 withMessage:@"You can share a single Photopon with no more than 10 friends"
                                  leftButton:nil
                                 rightButton:@"OK"
                                  leftAction:nil
                                 rightAction:nil];
                    
                    return;
                    
                }
                
            }
            
            NSMutableDictionary* mutableDict = [item mutableCopy];
            [mutableDict setValue:[NSNumber numberWithBool:selectedValue] forKey:@"isSelected"];
            [pendingFriends setObject:mutableDict atIndexedSubscript:indexPath.row];
            
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
        
    }*/
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0){
        return @"Friends";
    }else{
        return @"Pending Friends";
    }
}


@end













