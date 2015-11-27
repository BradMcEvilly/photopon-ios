//
//  MiniCouponView.m
//  Photopon
//
//  Created by Hayk Hayotsyan on 25/10/15.
//  Copyright © 2015 Photopon. All rights reserved.
//

#import "MiniCouponView.h"
#import <ImageIO/CGImageProperties.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "Helper.h"


@implementation MiniCouponView

{
    NSArray* allCoupons;
    NSArray* allPFCoupons;
    NSInteger currentCouponIndex;
    
    UISwipeGestureRecognizer *swipeRecLeft;
    UISwipeGestureRecognizer *swipeRecRight;
}




-(void)onSwipeLeft:(UISwipeGestureRecognizer *)gestureRecognizer {
    currentCouponIndex = (currentCouponIndex + 1) % [allCoupons count];
    [self createMiniCoupon];
}


-(void)onSwipeRight:(UISwipeGestureRecognizer *)gestureRecognizer {
    currentCouponIndex = (currentCouponIndex - 1 + [allCoupons count]) % [allCoupons count];
    [self createMiniCoupon];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        [otherGestureRecognizer requireGestureRecognizerToFail: swipeRecLeft];
        [otherGestureRecognizer requireGestureRecognizerToFail: swipeRecRight];
        
    }
    //NSLog(@"%@", otherGestureRecognizer);
    //[otherGestureRecognizer requireGestureRecognizerToFail:swipeRecLeft];
    //[otherGestureRecognizer requireGestureRecognizerToFail:swipeRecRight];
    return YES;
}

-(UIGestureRecognizer* _Nonnull)getRightSwipe {
    return swipeRecRight;
}

-(UIGestureRecognizer* _Nonnull)getLeftSwipe {
    return swipeRecLeft;
}


-(void)initView: (NSInteger)couponIndex
{
    currentCouponIndex = couponIndex;
    
    allCoupons = GetNearbyCoupons();
    allPFCoupons = GetNearbyCouponsPF();

    
    
    [self setUserInteractionEnabled:YES];
    
    swipeRecLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipeLeft:)];
    swipeRecLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:swipeRecLeft];
    
    swipeRecRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipeRight:)];
    swipeRecRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:swipeRecRight];
    
    
    swipeRecLeft.delegate = self;
    swipeRecRight.delegate = self;
    
    
    [self createMiniCoupon];
}


-(void)createMiniCoupon {
    NSArray *viewsToRemove = [self subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
    
    if ([allCoupons count] == 0) {
        return;
    }
    
    NSDictionary* coupon = [allCoupons objectAtIndex:currentCouponIndex];
    
    NSString* title = [coupon objectForKey:@"title"];
    NSString* desc = [coupon objectForKey:@"desc"];
    NSString* pic = [coupon objectForKey:@"pic"];
    
    int width = self.bounds.size.width;
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(120, 10, width - 120, 80)];
    titleLabel.text = title;
    titleLabel.numberOfLines = 1;
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    
    
    UILabel *descLabel = [[UILabel alloc]initWithFrame:CGRectMake(120, 100, width - 120, 80)];
    descLabel.text = desc;
    descLabel.numberOfLines = 1;
    descLabel.adjustsFontSizeToFitWidth = YES;
    descLabel.backgroundColor = [UIColor clearColor];
    descLabel.textColor = [UIColor whiteColor];
    descLabel.textAlignment = NSTextAlignmentCenter;
    
    
    
    
    UIImageView* image = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 100, 100)];
    [image sd_setImageWithURL:[NSURL URLWithString:pic] placeholderImage:[UIImage imageNamed:@"couponplaceholder.png"]];
    
    
    
    [self addSubview:titleLabel];
    [self addSubview:image];
}


@end
