//
//  WalletController.m
//  Photopon
//
//  Created by Hayk Hayotsyan on 30/8/15.
//  Copyright (c) 2015 Photopon. All rights reserved.
//

#import "WalletController.h"
#import "Parse/Parse.h"
#import "DBAccess.h"
#import "Helper.h"
#import "LogHelper.h"



@implementation WalletController
{
    NSMutableArray *allWalletItems;
}


-(void)viewDidLoad
{
    [super viewDidLoad];
    [self.walletTable setDelegate:self];
    [self.walletTable setDataSource:self];
    allWalletItems = [NSMutableArray array];
    
    GetNotifications(^(NSArray *results, NSError *error) {
        allWalletItems = [NSMutableArray arrayWithArray:results];
        [self.walletTable reloadData];
    });
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [allWalletItems count];
}





- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MyIdentifier"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    
    
    return cell;
}


@end
