//
//  CouponViewController.m
//  Photopon
//
//  Created by Hayk Hayotsyan on 21/8/15.
//  Copyright (c) 2015 Photopon. All rights reserved.
//

#import "CouponViewController.h"
#import "PhotoponDrawController.h"
#import "Parse/Parse.h"
#import "LogHelper.h"
#import "DBAccess.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "PhotoponCameraView.h"
#import "Helper.h"
#import "CouponTableViewCell.h"
#import "CouponDetailViewController.h"
#import "HeaderViewController.h"
#import "CouponWrapper.h"
#import "AlertBox.h"
#import "AvailabilityManager.h"
#import "PhotoponUnavailableViewController.h"

@interface CouponViewController()

@property (weak, nonatomic) IBOutlet UIView *notAvailableView;


@end

@implementation CouponViewController
{
    NSArray* allCoupons;
    NSArray* allPFCoupons;
    int selectedCouponIndex;
    CLLocationManager* locationManager;
    UIRefreshControl* refreshControl;
    NSInteger thisCouponIndex;
}




- (void) couponsUpdated {
    allCoupons = GetNearbyCoupons();
    allPFCoupons = GetNearbyCouponsPF();
    [self.couponTable reloadData];
    [refreshControl endRefreshing];
}


-(void)redeemCoupon {
    PFObject* coupon = [allPFCoupons objectAtIndex:thisCouponIndex];
    [coupon incrementKey:@"numRedeemed"];
    [coupon saveInBackground];
    
    [AlertBox showMessageFor:self withTitle:@"Your coupon"
                 withMessage:[NSString stringWithFormat:@"%@ %@", @"Your coupon code is: ", [coupon objectForKey:@"code"]]
                  leftButton:nil
                 rightButton:@"Awesome!"
                  leftAction:nil
                 rightAction:nil];
    
    
    
    SendGAEvent(@"user_action", @"coupons_table", @"got_coupon");
    CreateRedeemedLog(NULL, coupon);
    
}



-(void) getCoupon:(id)sender {
    UIButton* btn = (UIButton*)sender;
    thisCouponIndex = btn.tag;
    
    PFObject* coupon = [allPFCoupons objectAtIndex:thisCouponIndex];
    
    CouponWrapper* wrapper = [CouponWrapper fromObject:coupon];
    [wrapper getCoupon];
    SendGAEvent(@"user_action", @"coupons_table", @"get_clicked");
}

-(void) giveCoupon: (id)sender {
    UIButton* btn = (UIButton*)sender;
    NSInteger thisCouponIndex = btn.tag;

    [[NSNotificationCenter defaultCenter] postNotificationName:@"Goto_AddPhotopon" object:nil userInfo:@{
                                                                                                         @"index": @(thisCouponIndex)
                                                                                                         }];
    SendGAEvent(@"user_action", @"coupons_table", @"give_clicked");


}




-(void)viewWillAppear:(BOOL)animated {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"CouponsScreen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

-(void)forceUpdateCoupons {
    SendGAEvent(@"user_action", @"coupons_table", @"manual_update");
    UpdateNearbyCoupons();
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    HeaderViewController* header = [HeaderViewController addHeaderToView:self withTitle:@"Coupons"];
    [header setTheme:[UITheme greenTheme]];


    if ([AvailabilityManager photoponAvailable]) {
        [self.couponTable setDelegate:self];
        [self.couponTable setDataSource:self];

        allCoupons = GetNearbyCoupons();
        allPFCoupons = GetNearbyCouponsPF();
        [self.couponTable reloadData];

        NSLog(@"Registering listener for coupon update");
        AddCouponUpdateListener(self);

        refreshControl = [[UIRefreshControl alloc] init];
        refreshControl.backgroundColor = [UIColor whiteColor];
        refreshControl.tintColor = [UIColor blackColor];
        [refreshControl addTarget:self
                           action:@selector(forceUpdateCoupons)
                 forControlEvents:UIControlEventValueChanged];


        UITableViewController *tableViewController = [[UITableViewController alloc] init];
        tableViewController.tableView = self.couponTable;
        tableViewController.refreshControl = refreshControl;
        self.notAvailableView.hidden = YES;
    } else {
        self.notAvailableView.hidden = NO;
        [PhotoponUnavailableViewController addToViewController:self forView:self.notAvailableView];
    }

}

-(void) dealloc {
    RemoveCouponUpdateListener(self);
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [allCoupons count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CouponTableViewCell *cell = (CouponTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"CouponTableCell"];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CouponTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    NSDictionary *item = (NSDictionary *)[allCoupons objectAtIndex:indexPath.row];
    
    cell.title.text = [item objectForKey:@"title"];
    cell.longDescription.text = [item objectForKey:@"desc"];
    
    
    NSDate* exp = [item objectForKey:@"expiration"];
    NSDate* now = [NSDate date];
    
    int numDays = DaysBetween(now, exp);
    
    
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:@"MM/dd/yyyy"];
    cell.expiration.text = [NSString stringWithFormat:@"Expires %@", [dateFormater stringFromDate:exp]];
    if (numDays > 2) {
        [cell.expiration setTextColor:[UIColor colorWithRed:0 green:0.4 blue:0 alpha:1]];
    } else if (numDays > 1) {
        [cell.expiration setTextColor:[UIColor colorWithRed:0.6 green:0.3 blue:0 alpha:1]];
    } else {
        [cell.expiration setTextColor:[UIColor colorWithRed:0.4 green:0 blue:0 alpha:1]];
    }
    

    
    
    
    [cell.thumbImage sd_setImageWithURL:[NSURL URLWithString:[item objectForKey:@"pic"]] placeholderImage:[UIImage imageNamed:@"couponplaceholder.png"]];
    
    cell.getButton.tag = indexPath.row;
    [cell.getButton addTarget:self action:@selector(getCoupon:) forControlEvents:UIControlEventTouchDown];
    
    cell.giveButton.tag = indexPath.row;
    [cell.giveButton addTarget:self action:@selector(giveCoupon:) forControlEvents:UIControlEventTouchDown];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSInteger thisCouponIndex = (int)indexPath.row;
    
    CouponDetailViewController* detailView = (CouponDetailViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"SBCouponDetails"];
    [detailView setCouponIndex:thisCouponIndex];
    [self presentViewController:detailView animated:YES completion:nil];
    
}

- (IBAction)chatWithFriendsButtonHandler:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Goto_Friends" object:nil];
}

@end
