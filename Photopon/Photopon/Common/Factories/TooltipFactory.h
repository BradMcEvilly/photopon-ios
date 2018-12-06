//
//  TooltipFactory.h
//  Photopon
//
//  Created by Ante Karin on 26/08/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AMPopTip.h>

@interface TooltipFactory : NSObject

+ (AMPopTip *)showTakePhotoTooltipForView:(UIView *)view frame:(CGRect)frame;
+ (void)setTakePhotoTooltipChecked;

+ (AMPopTip *)showPersonalizeTooltipForView:(UIView *)view frame:(CGRect)frame;
+ (void)setPersonalizeTooltipChecked;

+ (AMPopTip *)showSwipeCouponsTooltipForView:(UIView *)view frame:(CGRect)frame;
+ (void)setSwipeCouponsTooltipForView;

+ (AMPopTip *)whyContactsRequiredTooltipForView:(UIView *)view frame:(CGRect)frame;
+ (void)setWhyContactsRequiredTooltipForView;

+ (AMPopTip *)showSharePhotoponForView:(UIView *)view frame:(CGRect)frame;
+ (void)setSharePhotoponTooltipChecked;

@end
