//
//  UIView+CommonLayout.h
//  NLB Pro
//
//  Created by Ante Karin on 03/05/16.
//  Copyright © 2016 infinum. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (CommonLayout)

- (void)addSubviewAndFill:(UIView *)view;
- (void)addSubviewAndPinTopAndLeftRight:(UIView *)view;
- (void)addSubviewAndPinLeftRightCenterVertical:(UIView *)view;

@end
