//
//  MiniCouponViewController.m
//  Photopon
//
//  Created by Hayk Hayotsyan on 18/12/15.
//  Copyright © 2015 Photopon. All rights reserved.
//

#import "MiniCouponViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>


@interface MiniCouponViewController ()

@end

@implementation MiniCouponViewController
{
    NSArray* allCoupons;
    NSArray* allPFCoupons;
    NSInteger currentCouponIndex;
    
    UISwipeGestureRecognizer *swipeRecLeft;
    UISwipeGestureRecognizer *swipeRecRight;
    
    BOOL isImmobile;
}


-(void)setCouponIndex: (NSInteger)couponIndex {
    currentCouponIndex = couponIndex;
    [self updateCoupon];
}

-(NSInteger)getCouponIndex {
    return currentCouponIndex;
}

-(PFObject*)getCoupon {
    return allPFCoupons[currentCouponIndex];
}

-(void)updateCoupon {
    if (currentCouponIndex >= [allCoupons count]) {
        return;
    }
    
    NSDictionary* coupon = [allCoupons objectAtIndex:currentCouponIndex];
    
    NSString* title = [coupon objectForKey:@"title"];
    NSString* desc = [coupon objectForKey:@"desc"];
    NSString* pic = [coupon objectForKey:@"pic"];
    
    [self.couponImage sd_setImageWithURL:[NSURL URLWithString:pic] placeholderImage:[UIImage imageNamed:@"couponplaceholder.png"]];
    
    self.couponTitle.text = title;
    self.couponDescription.text = desc;
     
}


-(void)onSwipeLeft:(UISwipeGestureRecognizer *)gestureRecognizer {
    if (isImmobile) return;
    
    currentCouponIndex = (currentCouponIndex + 1) % [allCoupons count];
    [self updateCoupon];
    SendGAEvent(@"user_action", @"minicouponview", @"swipe_left");
}


-(void)onSwipeRight:(UISwipeGestureRecognizer *)gestureRecognizer {
    if (isImmobile) return;
    
    
    currentCouponIndex = (currentCouponIndex - 1 + [allCoupons count]) % [allCoupons count];
    [self updateCoupon];
    
    SendGAEvent(@"user_action", @"minicouponview", @"swipe_right");
}



-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        [otherGestureRecognizer requireGestureRecognizerToFail: swipeRecLeft];
        [otherGestureRecognizer requireGestureRecognizerToFail: swipeRecRight];
        
    }

    return YES;
}


-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self couponsUpdated];
    [self updateCoupon];
}

-(void)setImmobile {
    isImmobile = TRUE;
}

-(void)couponsUpdated {
    allCoupons = GetNearbyCoupons();
    allPFCoupons = GetNearbyCouponsPF();
    self.view.hidden = ([allCoupons count] == 0);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
 
    
    
    [self.view setUserInteractionEnabled:YES];
    
    swipeRecLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipeLeft:)];
    swipeRecLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeRecLeft];
    
    swipeRecRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipeRight:)];
    swipeRecRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRecRight];
    
    
    
    swipeRecLeft.delegate = self;
    swipeRecRight.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
