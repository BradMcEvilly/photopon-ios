//
//  FriendsPickerTableViewController.m
//  Photopon
//
//  Created by Ante Karin on 23/10/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import "FriendsPickerViewController.h"
#import "FriendPickerCell.h"
#import <UIImageView+WebCache.h>
#import "UIColor+Convinience.h"
#import "UIColor+Theme.h"
#import "AlertBox.h"
#import "TooltipFactory.h"

@interface FriendsPickerViewController ()

@property (nonatomic, strong) NSMutableArray *myFriends;
@property (nonatomic, strong) NSNumber *giveToGet;
@property (nonatomic, strong) NSArray *myFriendsSorted;
@property (nonatomic, strong) NSMutableArray *myFriendsGrouped;
@property (nonatomic, strong) NSMutableArray *myFriendsKeys;
@property (nonatomic, strong) NSMutableSet *selectedFriends;
@property (nonatomic, strong) NSMutableString *giveToGetText;
@property (nonatomic, strong) AMPopTip *tooltip;

@end

@implementation FriendsPickerViewController {
    
    
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self initHeader];
    
    self.numSharesNeeded=NULL;
    
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    self.selectedFriends = [NSMutableSet new];
    
    [self.btnAddFriend addTarget:self action:@selector(addFriendClicked) forControlEvents:UIControlEventTouchDown];
    [self.btnAddMoreFriend addTarget:self action:@selector(addFriendClicked) forControlEvents:UIControlEventTouchDown];
    
    if (!self.tooltip) {
        if(!self.btnAddFriend.hidden){
            self.tooltip = [TooltipFactory whyContactsRequiredTooltipForView:self.view frame:[self.btnAddFriend convertRect:self.btnAddFriend.frame toView:self.view]];
        }else{
            self.tooltip = [TooltipFactory whyContactsRequiredTooltipForView:self.view frame:[self.btnAddMoreFriend convertRect:self.btnAddMoreFriend.frame toView:self.view]];
        }
    }
    [self updateHeaderView];
    [self loadFriends];
    
}

-(void)initHeader{
    self.tableView.tableHeaderView = self.tableHeaderView;
    if(self.currentCoupon){
        self.giveToGet = [self.currentCoupon valueForKey:@"givetoget"];
        self.giveToGetText = [NSMutableString stringWithFormat: @"Give to Get (%ld).", [self.giveToGet integerValue]];
        self.giveToGetTextView.text = self.giveToGetText;
    }
}

-(void)updateHeaderView{
    
    if(self.currentCoupon){
        NSNumber* giveToGet = [self.currentCoupon valueForKey:@"givetoget"];
        
        PFUser* user = [PFUser currentUser];
        
        PFQuery *query = [PFQuery queryWithClassName:@"PerUserShare"];
        [query includeKey:@"user"];
        [query includeKey:@"coupon"];
        [query includeKey:@"friend"];
        
        [query whereKey:@"user" equalTo:user];
        [query whereKey:@"coupon" equalTo:self.currentCoupon];
        
        [query countObjectsInBackgroundWithBlock:^(int number, NSError * _Nullable error) {
            
            int numNeeded=0;
            if (number >= [giveToGet integerValue]) {
                self.giveToGetText = [NSMutableString stringWithString: @"You can give this gift to as many friends as you'd like!"];
            } else {
                numNeeded = [giveToGet integerValue] - number;
                if (number == 0) {
                    self.giveToGetText = [NSMutableString stringWithFormat: @"Give this gift to %ld friends to unlock it.", numNeeded];
                } else {
                    self.giveToGetText = [NSMutableString stringWithFormat:@"You need to share this coupon with %i more friend%s before you can get it.", numNeeded, ((numNeeded > 1) ? "s" : "")];
                }
            }
            self.numSharesNeeded=[NSNumber numberWithInteger:numNeeded];
            self.giveToGetTextView.text = self.giveToGetText;
        }];
    }
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadFriends];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [TooltipFactory setWhyContactsRequiredTooltipForView];
}

-(void)addFriendClicked {
    SendGAEvent(@"user_action", @"friends_view", @"add_firend_clickede");
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    UIViewController *addFriend = [storyBoard instantiateViewControllerWithIdentifier:@"SBAddFriend"];
    [self.navigationController pushViewController:addFriend animated:true];
    
}

-(void)loadFriends {
    GetMyFriends(^(NSArray *results, NSError *error) {
        self.myFriends = [NSMutableArray new];
        NSLog(@"friends raw:");
        for (PFObject* obj in results) {
            
            NSLog(@"%@", obj);
            PFUser* object = (PFUser*)obj[@"user2"];

            if (object) {
                if ([self isExcluded: object]) {
                    continue;
                }

                [self.myFriends addObject:object];
            }
        }
        [self groupFriends];
        [self reloadData];
        
        [self.sendButton setEnabled:[self.selectedFriends count] != 0];
    });
}

-(void) reloadData{
    
    [self.tableView setHidden:self.myFriendsGrouped.count <= 0];
    [self.emptyView setHidden:self.myFriendsGrouped.count > 0];
    
    [self.tableView reloadData];
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
    
    NSLog(@"FriendsPickerViewController :: groupFriends :: myFriends.count");
    
    NSLog(@"Number of items in self.myFriends is: %d", [self.myFriends count]);
    
    for (int i = 0; i < [self.myFriends count]; ++i) {
        PFObject* obj = self.myFriends[i];
        NSLog(@"for loop %d", i);
        NSLog(@"%@", obj);
    }
    
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
    return (self.myFriendsGrouped.count > 0)? self.myFriendsGrouped.count + 1 : 0;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(section < self.myFriendsGrouped.count){
        return ((NSArray*)(self.myFriendsGrouped[section])).count;
    }else{
        return 1;
    }
    
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.section < self.myFriendsGrouped.count){
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
    }else{
        return self.cellAddMore;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section < self.myFriendsGrouped.count){
        
    PFObject *friend = self.myFriendsGrouped[indexPath.section][indexPath.row];

    FriendPickerCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    if ([self.selectedFriends containsObject:friend]) {
        [self.selectedFriends removeObject:friend];
        [cell setDeselectedState];
    } else {
        [self.selectedFriends addObject:friend];
        [cell setSelecteState];
    }
    
        [self.sendButton setEnabled:[self.selectedFriends count] != 0];
    }else{
       
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
    
    if(section < self.myFriendsGrouped.count){
    
        NSString *letter = self.myFriendsKeys[section];
        label.text = [[letter substringToIndex:1]uppercaseString];
    }else{
        return nil;
    }
    [view addSubview:label];
    view.layer.masksToBounds = YES;
    return view;
}

- (UINavigationController *)setupDefaultNavController {
    UINavigationController *navVC = [[UINavigationController alloc]initWithRootViewController:self];
    navVC.navigationBar.barTintColor = [UIColor giftsThemeColor];
    navVC.navigationBar.tintColor = [UIColor whiteColor];
    self.title = @"Share gift";
    
    UIImage *img = [UIImage imageNamed:@"confirm"];
    CGRect f = CGRectMake(0, 0, img.size.width, img.size.height);
    self.sendButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, img.size.width, img.size.height)];
    [self.sendButton setImage:img forState:UIControlStateNormal];
    [self.sendButton addTarget:self action:@selector(confirmedFriendsSelection) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.sendButton];
    
   
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"close-icon"] style:UIBarButtonItemStyleDone target:self action:@selector(cancelSelection)];
    
  
    return  navVC;
}

- (void)cancelSelection {
    [self.delegate didCancel];
}

- (void)confirmedFriendsSelection {
    [self.sendButton setEnabled:NO];
    [self.delegate didFinishSelecting:[self.selectedFriends allObjects] onComplete:^(NSError* error) {
        [self.sendButton setEnabled:YES];
        if(error != nil){
            
            
            [AlertBox showMessageFor:self
                           withTitle:@"Error"
                         withMessage: [error localizedDescription]
                          leftButton:nil
                         rightButton:@"OK"
                          leftAction:nil
                         rightAction:nil];
        }
    }];
}

@end
