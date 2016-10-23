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

@interface FriendsViewController()

@property (nonatomic, strong) AMPopTip *tooltip;
@property (nonatomic, weak) HeaderViewController *headerVC;
@property (nonatomic, strong) NSMutableArray *myFriendsPF;

@end

@implementation FriendsViewController
{
    NSMutableArray *myFriends;
    NSMutableArray* excludedFriends;
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
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"menu-icon"] style:UIBarButtonItemStylePlain target:self action:@selector(leftMenuClicked)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"add-friend-image"] style:UIBarButtonItemStylePlain target:self action:@selector(addFriendClicked)];

    [self.friendsTable registerNib:[UINib nibWithNibName:@"FriendTableViewCell" bundle:nil] forCellReuseIdentifier:@"FriendTableViewCell"];
    
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

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnTableView:)];
    [self.friendsTable addGestureRecognizer:tap];


}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:@"#61B8F2" alpha:1.0];
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
    [self presentViewController:addFriend animated:true completion:nil];

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
    
    GetMyFriends(^(NSArray *results, NSError *error) {
        [myFriends removeAllObjects];
        for (PFObject* obj in results) {
            PFUser* object = (PFUser*)obj[@"user2"];
            
            if (object) {
                if ([self isExcluded: object]) {
                    continue;
                }

                [myFriends addObject:object];
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
        int used = number;
        [query countObjectsInBackgroundWithBlock:^(int number, NSError * _Nullable error) {
            [friendCell setNumberOfGiftsUsed:used giftsShared:shared];
        }];
    }];


    PFFile* img = [item objectForKey:@"image"];
    if (img) {
        [friendCell.friendImageView sd_setImageWithURL:[NSURL URLWithString:img.url] placeholderImage:[UIImage imageNamed:@"profileplaceholder"]];
    }
    return friendCell;
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

}




@end













