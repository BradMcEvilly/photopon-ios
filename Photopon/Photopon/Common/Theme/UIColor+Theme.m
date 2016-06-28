//
//  UIColor+Theme.m
//  Photopon
//
//  Created by Ante Karin on 28/06/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import "UIColor+Theme.h"

@implementation UIColor (Theme)

+ (UIColor*)labelExpiryColorForDate:(NSDate *)date {
    NSDate* now = [NSDate date];

    int numDays = DaysBetween(now, date);
    if (numDays > 2) {
        return [UIColor colorWithRed:0 green:0.4 blue:0 alpha:1];
    } else if (numDays > 1) {
        return [UIColor colorWithRed:0.6 green:0.3 blue:0 alpha:1];
    } else {
        return [UIColor colorWithRed:0.4 green:0 blue:0 alpha:1];
    }
}


@end
