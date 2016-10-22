//
//  RoundedLabel.m
//  Photopon
//
//  Created by Ante Karin on 22/10/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import "RoundedLabel.h"

@implementation RoundedLabel

-(void)awakeFromNib {
    [super awakeFromNib];
    self.layer.cornerRadius = 12;
    self.layer.masksToBounds = YES;
}

- (CGSize)intrinsicContentSize {
    CGSize superSize = [super intrinsicContentSize];
    CGSize newSize = CGSizeMake(superSize.width + 20, superSize.height + 20);
    return newSize;
}

- (void)drawTextInRect:(CGRect)rect {
    UIEdgeInsets insets = {10, 10, 10, 10};
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

@end
