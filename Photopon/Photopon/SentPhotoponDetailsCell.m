//
//  SentPhotoponDetailsCell.m
//  Photopon
//
//  Created by Ante Karin on 06/11/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import "SentPhotoponDetailsCell.h"

@implementation SentPhotoponDetailsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.avatarImageView.layer.masksToBounds = YES;
    self.avatarImageView.layer.cornerRadius = 22;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
