//
//  FriendsPickerTableViewController.h
//  Photopon
//
//  Created by Ante Karin on 23/10/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FriendsPickerDelegate <NSObject>

- (void)didFinishSelecting:(NSArray *)friends onComplete:(void (^)(NSError *error))completeFunc;
- (void)didCancel;

@end

@interface FriendsPickerViewController : UIViewController

@property (nonatomic, strong)  NSMutableArray* excludedFriends;
@property (nonatomic, strong)  UIButton* sendButton;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *emptyView;
@property (weak, nonatomic) IBOutlet UIButton *btnAddFriend;
@property (weak, nonatomic) IBOutlet UIButton *btnAddMoreFriend;

@property (weak, nonatomic) IBOutlet UITableViewCell* cellAddMore;



@property (nonatomic, weak) id <FriendsPickerDelegate> delegate;

- (UINavigationController *)setupDefaultNavController;

@end
