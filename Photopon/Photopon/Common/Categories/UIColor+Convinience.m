//
//  UIColor+Convinience.m
//  Photopon
//
//  Created by Ante Karin on 29/09/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import "UIColor+Convinience.h"

@implementation UIColor (Convinience)

+ (UIColor *)colorWithHexString:(NSString *)hexString alpha:(CGFloat)alpha {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];

    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:alpha];
}

@end
