//
//  FriendsPickerTableViewController.m
//  Photopon
//
//  Created by Ante Karin on 23/10/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import "FriendsPickerTableViewController.h"
#import "FriendPickerCell.h"
#import <UIImageView+WebCache.h>
#import "UIColor+Convinience.h"
#import "UIColor+Theme.h"

@interface FriendsPickerTableViewController ()

@property (nonatomic, strong) NSMutableArray *myFriends;

@property (nonatomic, strong) NSArray *myFriendsSorted;
@property (nonatomic, strong) NSMutableArray *myFriendsGrouped;
@property (nonatomic, strong) NSMutableArray *myFriendsKeys;
@property (nonatomic, strong) NSMutableSet *selectedFriends;

@end

@implementation FriendsPickerTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    self.selectedFriends = [NSMutableSet new];
    [self loadFriends];
}

-(void)loadFriends {
    GetMyFriends(^(NSArray *results, NSError *error) {
        self.myFriends = [NSMutableArray new];
        for (PFObject* obj in results) {
            PFUser* object = (PFUser*)obj[@"user2"];

            if (object) {
                if ([self isExcluded: object]) {
                    continue;
                }

                [self.myFriends addObject:object];
            }
        }
        [self groupFriends];
        [self.tableView reloadData];
    });
}

-(BOOL)isExcluded:(PFUser*)user {
    for (int i = 0; i < [self.excludedFriends count]; ++i) {
        PFObject* obj = self.excludedFriends[i];
        if ([obj.objectId isEqualToString:user.objectId]) {
            return YES;
        }
    }
    return NO;
}

- (void)groupFriends {
    self.myFriendsSorted = [self.myFriends sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        PFObject *user1 = obj1;
        PFObject *user2 = obj2;

        NSString *name1 = user1[@"name"] ?: user1[@"username"];
        NSString *name2 = user2[@"name"] ?: user2[@"username"];

        name1 = name1.uppercaseString;
        name2 = name2.uppercaseString;

        return [name1 compare:name2 options:NSNumericSearch];
    }];

    self.myFriendsGrouped = [NSMutableArray new];
    self.myFriendsKeys = [NSMutableArray new];
    self.selectedFriends = [NSMutableSet new];

    for (PFObject *object in self.myFriendsSorted) {
        NSString *string = object[@"name"] ?: object[@"username"];
        NSString *firstLetter = [string substringToIndex:1];

        if (![self.myFriendsKeys containsObject:firstLetter]) {
            [self.myFriendsKeys addObject:firstLetter];
            [self.myFriendsGrouped addObject:[@[object]mutableCopy]];
        } else {
            NSMutableArray *array = self.myFriendsGrouped.lastObject;
            [array addObject:object];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.myFriendsGrouped.count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ((NSArray*)(self.myFriendsGrouped[section])).count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PFObject *user = self.myFriendsGrouped[indexPath.section][indexPath.row];

    FriendPickerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FriendPickerCell"];

    cell.titleLabel.text = user[@"name"] ?: user[@"username"];
    cell.subtitleLabel.text = user[@"email"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    if ([self.selectedFriends containsObject:user]) {
        [cell setSelecteState];
    } else {
        [cell setDeselectedState];
    }

    PFFile *image = user[@"image"];
    if (image) {
        [cell.userAvatarImageView sd_setImageWithURL:[NSURL URLWithString:image.url]];
    }

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PFObject *friend = self.myFriendsGrouped[indexPath.section][indexPath.row];

    FriendPickerCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    if ([self.selectedFriends containsObject:friend]) {
        [self.selectedFriends removeObject:friend];
        [cell setDeselectedState];
    } else {
        [self.selectedFriends addObject:friend];
        [cell setSelecteState];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 62;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 36;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIApplication sharedApplication].keyWindow.bounds.size.width, 36)];
    view.backgroundColor = [UIColor whiteColor];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(16, 0, 100, 36)];
    label.backgroundColor = [UIColor whiteColor];
    label.textColor = [UIColor colorWithHexString:@"#111111" alpha:1.0];
    NSString *letter = self.myFriendsKeys[section];
    label.text = [[letter substringToIndex:1]uppercaseString];
    [view addSubview:label];
    view.layer.masksToBounds = YES;
    return view;
}

- (UINavigationController *)setupDefaultNavController {
    UINavigationController *navVC = [[UINavigationController alloc]initWithRootViewController:self];
    navVC.navigationBar.barTintColor = [UIColor giftsThemeColor];
    navVC.navigationBar.tintColor = [UIColor whiteColor];
    self.title = @"Share gift";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"confirm"] style:UIBarButtonItemStyleDone target:self action:@selector(confirmedFriendsSelection)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"close-icon"] style:UIBarButtonItemStyleDone target:self action:@selector(cancelSelection)];
    return  navVC;
}

- (void)cancelSelection {
    [self.delegate didCancel];
}

- (void)confirmedFriendsSelection {
    [self.delegate didFinishSelecting:[self.selectedFriends allObjects]];
}

@end
