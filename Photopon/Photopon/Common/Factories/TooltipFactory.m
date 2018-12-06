//
//  TooltipFactory.m
//  Photopon
//
//  Created by Ante Karin on 26/08/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import "TooltipFactory.h"
#import "UIColor+Theme.h"

NSString * const TooltipTakePhotoCheckedKey = @"TooltipTakePhotoCheckedKey";
NSString * const TooltipPersonalizeCheckedKey = @"TooltipPersonalizeCheckedKey";
NSString * const TooltipSharePhotoponCheckedKey = @"TooltipSharePhotoponCheckedKey";
NSString * const TooltipSwipeCouponsCheckedKey = @"TooltipSwipeCouponsCheckedKey";
NSString * const TooltipWhyContactsNeededCheckedKey = @"TooltipWhyContactsNeededCheckedKey";

@implementation TooltipFactory

+ (AMPopTip *)showTakePhotoTooltipForView:(UIView *)view frame:(CGRect)frame {
    if ([[NSUserDefaults standardUserDefaults]objectForKey:TooltipTakePhotoCheckedKey]) {
        return nil;
    }

    AMPopTip *tooltip = [self createDefaultTooltip];
    [tooltip showText:@"Hello, when you are ready to start creating your first Photopon, use the shutter button!" direction:AMPopTipDirectionUp maxWidth:280 inView:view fromFrame:frame];
    return tooltip;
}

+ (void)setTakePhotoTooltipChecked {
    [[NSUserDefaults standardUserDefaults]setObject:@1 forKey:TooltipTakePhotoCheckedKey];
}

+ (AMPopTip *)showPersonalizeTooltipForView:(UIView *)view frame:(CGRect)frame {
    if ([[NSUserDefaults standardUserDefaults]objectForKey:TooltipPersonalizeCheckedKey]) {
        return nil;
    }

    AMPopTip *tooltip = [self createDefaultTooltip];
    [tooltip showText:@"Personalize your Photopon and use checkmark button when you are ready to share it" direction:AMPopTipDirectionUp maxWidth:280 inView:view fromFrame:frame];
    return tooltip;
}

+ (void)setPersonalizeTooltipChecked {
    [[NSUserDefaults standardUserDefaults]setObject:@1 forKey:TooltipPersonalizeCheckedKey];
}

+ (AMPopTip *)showSwipeCouponsTooltipForView:(UIView *)view frame:(CGRect)frame {
    if ([[NSUserDefaults standardUserDefaults]objectForKey:TooltipSwipeCouponsCheckedKey]) {
        return nil;
    }
    
    AMPopTip *tooltip = [self createDefaultTooltip];
    [tooltip showText:@"Swipe left or right to change coupon" direction:AMPopTipDirectionDown maxWidth:280 inView:view fromFrame:frame];
    return tooltip;
}

+ (void)setSwipeCouponsTooltipForView {
    [[NSUserDefaults standardUserDefaults]setObject:@1 forKey:TooltipSwipeCouponsCheckedKey];
}

+ (AMPopTip *)whyContactsRequiredTooltipForView:(UIView *)view frame:(CGRect)frame {
    if ([[NSUserDefaults standardUserDefaults]objectForKey:TooltipWhyContactsNeededCheckedKey]) {
        return nil;
    }
    
    AMPopTip *tooltip = [self createDefaultTooltip];
    [tooltip showText:@"To give your photopon gift to friends, you'll need to add contacts" direction:AMPopTipDirectionUp maxWidth:280 inView:view fromFrame:frame];
    //    [tooltip showText:@"To share your photopon, you'll need to add friends / contacts" direction:AMPopTipDirectionDown maxWidth:280 inView:view fromFrame:frame];
    return tooltip;
}

+ (void)setWhyContactsRequiredTooltipForView {
    [[NSUserDefaults standardUserDefaults]setObject:@1 forKey:TooltipWhyContactsNeededCheckedKey];
}

+ (AMPopTip *)showSharePhotoponForView:(UIView *)view frame:(CGRect)frame {
    if ([[NSUserDefaults standardUserDefaults]objectForKey:TooltipSharePhotoponCheckedKey]) {
        return nil;
    }

    AMPopTip *tooltip = [self createDefaultTooltip];
    [tooltip showText:@"Share your Photopon with your friends: select them from the list and tap on this button when ready. You can add friends from the Friends menu." direction:AMPopTipDirectionDown maxWidth:280 inView:view fromFrame:frame];
    return tooltip;
}

+ (void)setSharePhotoponTooltipChecked {
    [[NSUserDefaults standardUserDefaults]setObject:@1 forKey:TooltipSharePhotoponCheckedKey];
}

+ (AMPopTip *)createDefaultTooltip {
    AMPopTip *tooltip = [AMPopTip popTip];
    tooltip.shouldDismissOnTap = true;
    tooltip.entranceAnimation = AMPopTipEntranceAnimationFadeIn;
    tooltip.actionAnimation = AMPopTipActionAnimationFloat;
    tooltip.font = [UIFont fontWithName:@"Montserrat" size:19];
    tooltip.popoverColor = [UIColor giftsThemeColor];
    return tooltip;
}

@end
