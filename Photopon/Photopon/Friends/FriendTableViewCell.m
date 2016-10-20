//
//  FriendTableViewCell.m
//  Photopon
//
//  Created by Ante Karin on 15/10/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import "FriendTableViewCell.h"

@implementation FriendTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.friendImageView.layer.cornerRadius = 22;
    self.friendImageView.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setName:(NSString *)name username:(NSString *)username {
    if (!username) {
        username = @"";
    }
    self.friendUsernameLabel.text = [NSString stringWithFormat:@"%@ %@", name, username];
}

- (void)setNumberOfGiftsUsed:(NSInteger)giftsUsed giftsShared:(NSInteger)giftsShared {
    self.friendShareInfoLabel.text = [NSString stringWithFormat:@"%ld gifts shared・%ld used", (long)giftsShared, (long)giftsUsed];
}

@end
