//
//  RoundedBorderedLabel.m
//  Photopon
//
//  Created by Ante Karin on 22/10/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import "RoundedBorderedLabel.h"
#import "UIColor+Convinience.h"

@implementation RoundedBorderedLabel

-(void)awakeFromNib {
    [super awakeFromNib];
    self.layer.borderWidth = 1;
    self.layer.borderColor = [UIColor colorWithHexString:@"C0C0C0" alpha:0.3].CGColor;
}

@end
