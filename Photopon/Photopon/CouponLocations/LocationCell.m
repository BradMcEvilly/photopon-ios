//
//  LocationCell.m
//  Photopon
//
//  Created by Ante Karin on 21/07/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import "LocationCell.h"
#import "NSString+FontAwesome.h"

@implementation LocationCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.iconLabel.text = [NSString fontAwesomeIconStringForEnum:FALocationArrow];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
