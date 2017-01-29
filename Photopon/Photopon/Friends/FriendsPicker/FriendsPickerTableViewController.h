//
//  FriendsPickerTableViewController.h
//  Photopon
//
//  Created by Ante Karin on 23/10/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FriendsPickerDelegate <NSObject>

- (void)didFinishSelecting:(NSArray *)friends;
- (void)didCancel;

@end

@interface FriendsPickerTableViewController : UITableViewController

@property (nonatomic, strong)  NSMutableArray* excludedFriends;

@property (nonatomic, weak) id <FriendsPickerDelegate> delegate;

- (UINavigationController *)setupDefaultNavController;

@end
