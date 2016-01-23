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



@implementation WalletController
{
    NSMutableArray *allWalletItems;
    int selectedItemIndex;
}


-(void)viewDidLoad
{
    [super viewDidLoad];
    [HeaderViewController addHeaderToView:self withTitle:@"Wallet"];

    [self.walletTable setDelegate:self];
    [self.walletTable setDataSource:self];
    allWalletItems = [NSMutableArray array];
    
    GetWalletItems(^(NSArray *results, NSError *error) {
        allWalletItems = [NSMutableArray arrayWithArray:results];
        [self.walletTable reloadData];
    });
    
}





-(void)viewWillAppear:(BOOL)animated {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"WalletScreen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
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




- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedItemIndex = (int)indexPath.row;
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Choose action"
                                                                   message:@"Do you want to Redeem this photopon now?"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* getAction = [UIAlertAction actionWithTitle:@"Redeem" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        PFObject* walletItem = [allWalletItems objectAtIndex:selectedItemIndex];
        PFObject* photopon = [walletItem objectForKey:@"photopon"];
        PFObject* coupon = [photopon objectForKey:@"coupon"];
        
        [photopon incrementKey:@"numRedeemed"];
        [photopon saveInBackground];
        
        [coupon incrementKey:@"numRedeemed"];
        [coupon saveInBackground];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Your coupon"
                                                        message:[NSString stringWithFormat:@"%@ %@", @"Your coupon code is: ", [coupon objectForKey:@"code"]]
                                                       delegate:nil
                                              cancelButtonTitle:@"Awesome!"
                                              otherButtonTitles:nil];
        [alert show];
    }];
    
    
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        
    }];
    
    [alert addAction:getAction];
    [alert addAction:cancelAction];
    
    
    
    [self presentViewController:alert animated:YES completion:nil];
    
    
    
    
    /*
     PhotoponCameraView* camView = (PhotoponCameraView*)[self.storyboard instantiateViewControllerWithIdentifier:@"SBPhotoponCam"];
     
     [camView setCoupons:allCoupons withObjects:allPFCoupons];
     [camView setCurrentCouponIndex:indexPath.row];
     [self showViewController:camView sender:nil];
     */
}


@end
