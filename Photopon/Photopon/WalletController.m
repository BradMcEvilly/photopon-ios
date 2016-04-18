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


@implementation WalletController
{
    NSMutableArray *allWalletItems;
    int selectedItemIndex;
}

-(void)updateWallet {
    allWalletItems = [NSMutableArray array];
    
    GetWalletItems(^(NSArray *results, NSError *error) {
        allWalletItems = [NSMutableArray arrayWithArray:results];
        [self.walletTable reloadData];
    });

}


-(void)viewDidLoad
{
    [super viewDidLoad];
    HeaderViewController* header = [HeaderViewController addHeaderToView:self withTitle:@"Wallet"];
    [header setTheme:[UITheme orangeTheme]];

    [self.walletTable setDelegate:self];
    [self.walletTable setDataSource:self];
    [self updateWallet];
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





- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MyIdentifier"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    
    NSDictionary *item = (NSDictionary *)[allWalletItems objectAtIndex:indexPath.row];

    PFObject* photopon = [item objectForKey:@"photopon"];
    
    cell.textLabel.text = [photopon objectForKey:@"title"];
    
    
    NSDate *created = [photopon createdAt];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"EEE, MMM d, h:mm a"];
    
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Sent by %@ at %@", [[photopon objectForKey:@"creator"] username], [dateFormat stringFromDate:created]];
    
    PFObject* coupon = [photopon objectForKey:@"coupon"];
    PFObject* company = [coupon objectForKey:@"company"];
    PFFile* logo = [company objectForKey:@"image"];
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:logo.url] placeholderImage:[UIImage imageNamed:@"couponplaceholder.png"]];
    

    
    
    return cell;
}


-(void)redeemCoupon {
    PFObject* walletItem = [allWalletItems objectAtIndex:selectedItemIndex];
    PFObject* photopon = [walletItem objectForKey:@"photopon"];
    PFObject* coupon = [photopon objectForKey:@"coupon"];
    
    [photopon incrementKey:@"numRedeemed"];
    [photopon saveInBackground];
    
    [coupon incrementKey:@"numRedeemed"];
    [coupon saveInBackground];
    
    [walletItem setValue:[NSNumber numberWithBool:YES] forKey:@"isUsed"];
    [walletItem saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [self updateWallet];
    }];
    
    SendGAEvent(@"user_action", @"wallet", @"redeem_clicked");
    
    
    [AlertBox showMessageFor:self withTitle:@"Your coupon"
                 withMessage:[NSString stringWithFormat:@"%@ %@", @"Your coupon code is: ", [coupon objectForKey:@"code"]]
                  leftButton:nil
                 rightButton:@"Awesome!"
                  leftAction:nil
                 rightAction:nil];
    
    
    
    CreateRedeemedNotification([photopon valueForKey:@"creator"], photopon);
    CreateRedeemedLog([photopon valueForKey:@"creator"], coupon);

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedItemIndex = (int)indexPath.row;
    SendGAEvent(@"user_action", @"wallet", @"wallet_item_clicked");
    
    
    [AlertBox showMessageFor:self
                   withTitle:@"Choose action"
                 withMessage:@"Do you want to Redeem this photopon now?"
                  leftButton:@"Cancel"
                 rightButton:@"Redeem"
                  leftAction:nil
                 rightAction:@selector(redeemCoupon)];
}


@end
