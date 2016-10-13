//
//  SentCouponCell.m
//  Photopon
//
//  Created by Ante Karin on 10/10/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import "SentCouponCell.h"
#import "UIColor+Convinience.h"

@implementation SentCouponCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.avatarImageView.layer.cornerRadius = 22;
    self.avatarImageView.layer.masksToBounds = YES;

    self.couponContainerView.corners = UIRectCornerAllCorners;
    self.couponContainerView.borderColor = [UIColor colorWithHexString:@"#COCOCO" alpha:0.2];
}

@end
