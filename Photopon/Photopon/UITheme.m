//
//  UITheme.m
//  Photopon
//
//  Created by Hayk Hayotsyan on 2/2/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import "UITheme.h"
#import "UIColor+Convinience.h"

@implementation UITheme


+(UITheme*)themeWithHeaderColor: (UIColor*)headerColor headerTextColor:(UIColor*)headerTextColor {
    UITheme* theme = [UITheme alloc];
    theme.headerColor = headerColor;
    theme.headerTextColor = headerTextColor;
    return theme;
}


+(UITheme*)whiteTheme {
    return [UITheme themeWithHeaderColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1]
                         headerTextColor:[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1]];
}

+(UITheme*)greenTheme {
    return [UITheme themeWithHeaderColor:[UIColor colorWithRed:0.15 green:0.72 blue:0.34 alpha:1]
                         headerTextColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1]];
}

+(UITheme*)pinkTheme {
    return [UITheme themeWithHeaderColor:[UIColor colorWithHexString:@"#D94CCB" alpha:1.0]
                         headerTextColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1]];
}

+(UITheme*)orangeTheme {
    return [UITheme themeWithHeaderColor:[UIColor colorWithRed:1 green:0.5 blue:0.23 alpha:1]
                         headerTextColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1]];
}

+(UITheme*)blackTheme {
    return [UITheme themeWithHeaderColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1]
                         headerTextColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1]];
}

+(UITheme*)blueTheme {
    return [UITheme themeWithHeaderColor:[UIColor colorWithRed:0.2 green:0.37 blue:0.6 alpha:1]
                         headerTextColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1]];
}

+(UITheme*)tealTheme {
    return [UITheme themeWithHeaderColor:[UIColor colorWithRed:0 green:0.6 blue:0.53 alpha:1]
                         headerTextColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1]];
}


+(UITheme*)redTheme {
    return [UITheme themeWithHeaderColor:[UIColor colorWithRed:0.8 green:0.08 blue:0.08 alpha:1]
                         headerTextColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1]];
}

+(UITheme*)yellowTheme {
    return [UITheme themeWithHeaderColor:[UIColor colorWithRed:0.95 green:0.73 blue:0 alpha:1]
                         headerTextColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:1]];
}

@end
