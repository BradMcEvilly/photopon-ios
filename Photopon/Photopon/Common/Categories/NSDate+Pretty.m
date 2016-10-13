//
//  NSDate+Pretty.m
//  Photopon
//
//  Created by Ante Karin on 13/10/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import "NSDate+Pretty.h"

@implementation NSDate (Pretty)

- (NSString *)prettyString {
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:@"MM/dd/yyyy"];
    return [dateFormater stringFromDate:self];

}

@end
