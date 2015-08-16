//
//  FriendRequestControl.h
//  Photopon
//
//  Created by Hayk Hayotsyan on 14/8/15.
//  Copyright (c) 2015 Photopon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendRequestControl : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *requestTable;
@property (weak, nonatomic) IBOutlet UILabel *noRequests;

@end
