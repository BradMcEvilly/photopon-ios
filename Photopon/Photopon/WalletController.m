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
#import <SDWebImage/UIImageView+WebCache.h>
#import "HeaderViewController.h"
#import "AlertBox.h"
#import "PhotoponWrapper.h"
#import "CouponWrapper.h"
#import "CouponDefaultCell.h"
#import "NSDate+Pretty.h"
#import "UIViewController+Menu.h"

@implementation WalletController
{
    NSMutableArray *allWalletItems;
    int selectedItemIndex;
     UIRefreshControl* refreshControl;
}

-(void)updateWallet {
    allWalletItems = [NSMutableArray array];
    [self.emptyView setHidden:YES];
    
    GetWalletItems(^(NSArray *results, NSError *error) {
        allWalletItems = [NSMutableArray arrayWithArray:results];
        [self.emptyView setHidden:allWalletItems.count > 0];
        
        [self.walletTable reloadData];
        [refreshControl endRefreshing];
        
    });

}


-(void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"menu-icon"] style:UIBarButtonItemStylePlain target:self action:@selector(leftMenuClicked)];
    
    [self.walletTable registerNib:[UINib nibWithNibName:@"CouponDefaultCell" bundle:nil] forCellReuseIdentifier:@"CouponDefaultCell"];

    self.walletTable.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
    [self.walletTable setDelegate:self];
    [self.walletTable setDataSource:self];
    [self updateWallet];
    
    
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.backgroundColor = [UIColor whiteColor];
    refreshControl.tintColor = [UIColor blackColor];
    [refreshControl addTarget:self
                       action:@selector(updateWallet)
             forControlEvents:UIControlEventValueChanged];
    
    
    UITableViewController *tableViewController = [[UITableViewController alloc] init];
    tableViewController.tableView = self.walletTable;
    tableViewController.refreshControl = refreshControl;

}


-(void)viewWillAppear:(BOOL)animated {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"WalletScreen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    [self updateWallet];
}





- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [allWalletItems count];
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 130;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CouponDefaultCell *couponCell = [tableView dequeueReusableCellWithIdentifier:@"CouponDefaultCell"];

    NSDictionary *item = (NSDictionary *)[allWalletItems objectAtIndex:indexPath.row];

    PFObject* photopon = [item objectForKey:@"photopon"];
    PFObject* coupon = [photopon objectForKey:@"coupon"];
    couponCell.titleLabel = [coupon objectForKey:@"title"];
    
    
    NSDate *created = [photopon createdAt];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"EEE, MMM d, h:mm a"];
    
    
    couponCell.subtitleLabel.text = [NSString stringWithFormat:@"Sent by %@ at %@", [[photopon objectForKey:@"creator"] username], [dateFormat stringFromDate:created]];

    NSDate *expiration = coupon[@"expiration"];
    couponCell.expirationLabel.text = [expiration prettyString];

    
    PFObject* company = [coupon objectForKey:@"company"];
    PFFile* logo = [company objectForKey:@"image"];
    [couponCell.brandImageView sd_setImageWithURL:[NSURL URLWithString:logo.url] placeholderImage:[UIImage imageNamed:@"couponplaceholder.png"]];
    

    return couponCell;
}


-(void)redeemCoupon {
    PFObject* walletItem = [allWalletItems objectAtIndex:selectedItemIndex];
    
    PFObject* photopon = [walletItem objectForKey:@"photopon"];
    [[PhotoponWrapper fromObject:photopon] redeem];
    
    
    [walletItem setValue:[NSNumber numberWithBool:YES] forKey:@"isUsed"];
    [walletItem saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [self updateWallet];
    }];
}

-(void)removeWalletItem {
    PFObject* walletItem = [allWalletItems objectAtIndex:selectedItemIndex];

    [walletItem setValue:[NSNumber numberWithBool:YES] forKey:@"isUsed"];
    [walletItem saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [self updateWallet];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedItemIndex = (int)indexPath.row;
    SendGAEvent(@"user_action", @"wallet", @"wallet_item_clicked");
    
    PFObject* walletItem = [allWalletItems objectAtIndex:selectedItemIndex];
    
    PFObject* photopon = [walletItem objectForKey:@"photopon"];
    PFObject* coupon = [photopon objectForKey:@"coupon"];
    
    //[[CouponWrapper fromObject:coupon] isRedeemed] redeem];
    [[CouponWrapper fromObject:coupon] isRedeemed:^(BOOL value) {
        if (!value) {
            [AlertBox showMessageFor:self
                           withTitle:@"Choose action"
                         withMessage:@"Do you want to Redeem this photopon now?"
                          leftButton:@"Cancel"
                         rightButton:@"Redeem"
                          leftAction:nil
                         rightAction:@selector(redeemCoupon)];
        } else {
            [AlertBox showMessageFor:self
                           withTitle:@"Redeemed"
                         withMessage:@"You have already redeemed this coupon."
                          leftButton:nil
                         rightButton:@"OK"
                          leftAction:nil
                         rightAction:@selector(removeWalletItem)];
        }
    }];

   
}


@end
