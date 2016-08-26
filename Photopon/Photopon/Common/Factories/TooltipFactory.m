//
//  TooltipFactory.m
//  Photopon
//
//  Created by Ante Karin on 26/08/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import "TooltipFactory.h"

NSString * const TooltipTutorialShownKey = @"TooltipTutorialShownKey";

@implementation TooltipFactory

+ (AMPopTip *)showTakePhotoTooltipForView:(UIView *)view frame:(CGRect)frame {
    if ([[NSUserDefaults standardUserDefaults]objectForKey:TooltipTutorialShownKey]) {
//        return nil;
    }

    AMPopTip *tooltip = [self createDefaultTooltip];
    [tooltip showText:@"Hello, when you are ready to start creating your first Photopon use the shutter button! " direction:AMPopTipDirectionUp maxWidth:280 inView:view fromFrame:frame];
    [[NSUserDefaults standardUserDefaults]setObject:@1 forKey:TooltipTutorialShownKey];
    return tooltip;
}

+ (AMPopTip *)createDefaultTooltip {
    AMPopTip *tooltip = [AMPopTip popTip];
    tooltip.shouldDismissOnTap = true;
    tooltip.entranceAnimation = AMPopTipEntranceAnimationTransition;
    tooltip.actionAnimation = AMPopTipActionAnimationFloat;
    return tooltip;
}

@end
