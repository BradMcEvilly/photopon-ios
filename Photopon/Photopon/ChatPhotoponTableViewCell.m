//
//  ChatPhotoponTableViewCell.m
//  Photopon
//
//  Created by Roman Temchenko on 2016-06-13.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import "ChatPhotoponTableViewCell.h"
#import "ChatPhotoponPresentableModel.h"

@implementation ChatPhotoponTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.containerView.layer.cornerRadius = 4.0;
    self.containerView.layer.borderWidth = 1.0;
    self.containerView.layer.borderColor = [UIColor blackColor].CGColor;
}

- (void)updateWithPresentableModel:(ChatPhotoponPresentableModel *)presentableModel
{
    self.leftIndicator.hidden = presentableModel.isCurrentUser;
    self.rightIndicator.hidden = !presentableModel.isCurrentUser;
    self.statusLabel.text = presentableModel.photoponStatus;
    self.titleLabel.text = presentableModel.couponTitle;
}

@end
