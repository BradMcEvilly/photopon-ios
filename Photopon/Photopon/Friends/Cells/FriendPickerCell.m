//
//  FriendPickerCell.m
//  Photopon
//
//  Created by Ante Karin on 23/10/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import "FriendPickerCell.h"

@implementation FriendPickerCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.userAvatarImageView.layer.cornerRadius = 22;
    self.userAvatarImageView.layer.masksToBounds = YES;
}

- (void)setSelecteState {
    self.selectionImageView.image = [UIImage imageNamed:@"selected-picker-image"];
}

- (void)setDeselectedState {
    self.selectionImageView.image = [UIImage imageNamed:@"deselected-picker-image"];
}

@end
