//
//  WalletController.h
//  Photopon
//
//  Created by Hayk Hayotsyan on 30/8/15.
//  Copyright (c) 2015 Photopon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WalletController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *walletTable;
@property (weak, nonatomic) IBOutlet UIView *emptyView;

@end
