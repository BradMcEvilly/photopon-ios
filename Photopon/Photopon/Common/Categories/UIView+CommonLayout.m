//
//  UIView+CommonLayout.m
//  NLB Pro
//
//  Created by Ante Karin on 03/05/16.
//  Copyright © 2016 infinum. All rights reserved.
//

#import "UIView+CommonLayout.h"

@implementation UIView (CommonLayout)

- (void)addSubviewAndFill:(UIView *)view {
    [self addSubview:view];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:NSLayoutFormatAlignAllTop metrics:nil views:@{@"view": view}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:NSLayoutFormatAlignAllTop metrics:nil views:@{@"view": view}]];
    view.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)addSubviewAndPinTopAndLeftRight:(UIView *)view {
    [self addSubview:view];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:NSLayoutFormatAlignAllTop metrics:nil views:@{@"view": view}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]" options:NSLayoutFormatAlignAllTop metrics:nil views:@{@"view": view}]];
    view.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)addSubviewAndPinLeftRightCenterVertical:(UIView *)view {
    [self addSubview:view];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:NSLayoutFormatAlignAllBaseline metrics:nil views:@{@"view": view}]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    view.translatesAutoresizingMaskIntoConstraints = NO;
}
@end
