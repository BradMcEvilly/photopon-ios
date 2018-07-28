//
//  PPTableViewCell.m
//  Photopon
//
//  Created by Damien Rottemberg on 2/6/18.
//  Copyright © 2018 Photopon. All rights reserved.
//

#import "PPTableViewCell.h"

@implementation PPTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(0,0,44,44);
}

@end
