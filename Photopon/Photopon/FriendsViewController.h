//
//  FriendsViewController.h
//  Photopon
//
//  Created by Hayk Hayotsyan on 12/8/15.
//  Copyright (c) 2015 Photopon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface FriendsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *friendsTable;

-(void)friendSelectedCallBack:(SEL)action target:(id)target;
-(void)updateFriends;
@end
