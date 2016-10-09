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
#import "UIViewController+Menu.h"
#import "CouponDetailsViewController.h"
#import "MultipleLocationsContainerViewController.h"
#import "CouponLocationsTableViewController.h"

@interface CouponViewController()

@property (weak, nonatomic) IBOutlet UIView *notAvailableView;

@property (nonatomic, strong) NSArray *mockCoupons;

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
    
    if (!HasPhoneNumber(@"Please add and verify your mobile phone number to get this coupon.")) {
        return;
    }
    
    UIButton* btn = (UIButton*)sender;
    thisCouponIndex = btn.tag;
    
    PFObject* coupon = [allPFCoupons objectAtIndex:thisCouponIndex];
    
    CouponWrapper* wrapper = [CouponWrapper fromObject:coupon];
    [wrapper getCoupon];
    SendGAEvent(@"user_action", @"coupons_table", @"get_clicked");
}

-(void) giveCoupon: (id)sender {
    if (!HasPhoneNumber(@"Please add and verify your mobile phone number to give this coupon.")) {
        return;
    }
    
    
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
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

-(void)forceUpdateCoupons {
    SendGAEvent(@"user_action", @"coupons_table", @"manual_update");
    UpdateNearbyCoupons();
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];

#ifdef DEBUG
    self.mockCoupons = @[ @{@"title": @"Test Coupon Buy 1 get 1 Free",
                            @"desc": @"Get 1 free for 1 bought",
                            @"expiration": [NSDate dateWithTimeIntervalSinceNow:360000],
                            @"pic": @"http://graphichive.net/uploaded/fordesigner/1313309042.jpg",
                            @"redeemed": @0},
                          @{@"title": @"Test Coupon Buy 1 get 1 Free",
                            @"desc": @"Get 1 free for 1 bought",
                            @"expiration": [NSDate dateWithTimeIntervalSinceNow:60000],
                            @"pic": @"https://aletp.com/images/blog/adidas-logo1.jpg",
                            @"redeemed": @0},
                          @{@"title": @"Test Coupon Buy 1 get 1 Free",
                            @"desc": @"Get 1 free for 1 bought",
                            @"expiration": [NSDate dateWithTimeIntervalSinceNow:2360000],
                            @"pic": @"https://aletp.com/images/blog/adidas-logo1.jpg",
                            @"redeemed": @0}
                          ];
#endif
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"menu-icon"] style:UIBarButtonItemStylePlain target:self action:@selector(leftMenuClicked)];
    self.title = @"Gifts";

    
    
    [self.couponTable setDelegate:self];
    [self.couponTable setDataSource:self];
    self.couponTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
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

    [self photoponAvailabilityConfiguration];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(photoponAvailabilityConfiguration) name:NOTIFICATION_PHOTOPON_AVAILABLE object:nil];
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
//#ifdef DEBUG
//    return self.mockCoupons.count;
//#endif
    return [allPFCoupons count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CouponTableViewCell *cell = (CouponTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"CouponTableCell"];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CouponTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    


//#ifdef DEBUG
//    NSDictionary *item = self.mockCoupons[indexPath.row];
//#elif
    PFObject *item = [allPFCoupons objectAtIndex:indexPath.row];
//#endif

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
    
    cell.getButton.hidden = [item[@"redeemed"] boolValue];
        
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 189;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{   [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    NSInteger thisCellIndex = (int)indexPath.row;
//
//    CouponDetailViewController* detailView = (CouponDetailViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"SBCouponDetails"];
//    [detailView setCouponIndex:thisCellIndex];
//
//    //UINavigationController *navVC = [[UINavigationController alloc]initWithRootViewController:detailView];
//    //navVC.navigationBarHidden = YES;
//    [self presentViewController:detailView animated:YES completion:nil];
    NSArray *couponLocations = [allPFCoupons[selectedCouponIndex] objectForKey:@"locations"];
    if (couponLocations.count == 1) {
        CouponDetailsViewController *detailsVC = [[UIStoryboard storyboardWithName:@"CouponDetails" bundle:nil]instantiateViewControllerWithIdentifier:@"CouponDetailsViewController"];
        detailsVC.coupon = allPFCoupons[selectedCouponIndex];
        detailsVC.selectedCouponIndex = selectedCouponIndex;
        detailsVC.location = couponLocations.firstObject;
        [self.navigationController pushViewController:detailsVC animated:YES];
    } else {
        CouponLocationsTableViewController *vc = [[UIStoryboard storyboardWithName:@"CouponDetails" bundle:nil]instantiateViewControllerWithIdentifier:@"CouponLocationsTableViewController"];
        vc.coupon = allPFCoupons[selectedCouponIndex];
        vc.selectedCouponIndex = selectedCouponIndex;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)chatWithFriendsButtonHandler:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Goto_Friends" object:nil];
}

#pragma mark - Availability

- (void)photoponAvailabilityConfiguration {
    if ([AvailabilityManager photoponAvailable]) {
        self.notAvailableView.hidden = YES;
    } else {
        self.notAvailableView.hidden = NO;
        [PhotoponUnavailableViewController addToViewController:self forView:self.notAvailableView];
    }
}

@end
