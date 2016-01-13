//
//  MiniCouponViewController.h
//  Photopon
//
//  Created by Hayk Hayotsyan on 18/12/15.
//  Copyright © 2015 Photopon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MiniCouponViewController : UIViewController<UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *couponImage;
@property (weak, nonatomic) IBOutlet UILabel *couponTitle;
@property (weak, nonatomic) IBOutlet UILabel *couponDescription;


-(NSInteger)getCouponIndex;
-(void)setCouponIndex: (NSInteger)couponIndex;
-(void)setImmobile;
    
@end
