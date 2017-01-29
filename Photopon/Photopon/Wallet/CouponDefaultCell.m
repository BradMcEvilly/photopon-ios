//
//  CouponDefaultCell.m
//  Photopon
//
//  Created by Ante Karin on 14/10/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import "CouponDefaultCell.h"
#import "UIColor+Convinience.h"

@implementation CouponDefaultCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.container.corners = UIRectCornerAllCorners;
    self.container.borderColor = [UIColor colorWithHexString:@"#COCOCO" alpha:0.2];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
