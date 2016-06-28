//
//  NSDateFormatter+Common.m
//  Photopon
//
//  Created by Ante Karin on 28/06/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import "NSDateFormatter+Common.h"

@implementation NSDateFormatter (Common)

+ (NSDateFormatter *)defaultDateFormatter {
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:@"MM/dd/yyyy"];
    return dateFormater;
}

@end
