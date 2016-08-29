//
//  TooltipFactory.m
//  Photopon
//
//  Created by Ante Karin on 26/08/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import "TooltipFactory.h"

NSString * const TooltipTakePhotoCheckedKey = @"TooltipTakePhotoCheckedKey";
NSString * const TooltipPersonalizeCheckedKey = @"TooltipPersonalizeCheckedKey";

@implementation TooltipFactory

+ (AMPopTip *)showTakePhotoTooltipForView:(UIView *)view frame:(CGRect)frame {
    if ([[NSUserDefaults standardUserDefaults]objectForKey:TooltipTakePhotoCheckedKey]) {
        return nil;
    }

    AMPopTip *tooltip = [self createDefaultTooltip];
    [tooltip showText:@"Hello, when you are ready to start creating your first Photopon use the shutter button!" direction:AMPopTipDirectionUp maxWidth:280 inView:view fromFrame:frame];
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

+ (AMPopTip *)createDefaultTooltip {
    AMPopTip *tooltip = [AMPopTip popTip];
    tooltip.shouldDismissOnTap = true;
    tooltip.entranceAnimation = AMPopTipEntranceAnimationTransition;
    tooltip.actionAnimation = AMPopTipActionAnimationFloat;
    tooltip.font = [UIFont boldSystemFontOfSize:15];
    tooltip.popoverColor = [UIColor orangeColor];
    return tooltip;
}

@end
