//
//  CouponTableViewCell.m
//  Photopon
//
//  Created by Hayk Hayotsyan on 19/11/15.
//  Copyright © 2015 Photopon. All rights reserved.
//

#import "CouponTableViewCell.h"
#import "UIColor+Convinience.h"

@implementation CouponTableViewCell


- (void)awakeFromNib {
    [super awakeFromNib];

    self.containerView.layer.cornerRadius = 12;
    self.containerView.layer.masksToBounds = YES;
    self.containerView.layer.borderWidth = 1;
    self.containerView.layer.borderColor = [[UIColor colorWithHexString:@"#C0C0C0" alpha:0.3] CGColor];
    self.verticalDividerView.image = [[UIImage imageNamed:@"vertical-divider"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    if (selected) {
        self.containerView.backgroundColor = [UIColor colorWithHexString:@"#ACACAC" alpha:0.3];
    } else {
        self.containerView.backgroundColor = [UIColor whiteColor];
    }
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [self setSelected:highlighted animated:animated];
}

@end
