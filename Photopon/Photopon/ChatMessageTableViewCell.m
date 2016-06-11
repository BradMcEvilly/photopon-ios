//
//  ChatMessageTableViewCell.m
//  Photopon
//
//  Created by Hayk Hayotsyan on 9/12/15.
//  Copyright © 2015 Photopon. All rights reserved.
//

#import "ChatMessageTableViewCell.h"
#import "ChatMessagePresentableModel.h"

@implementation ChatMessageTableViewCell

- (void)updateWithPresentableModel:(ChatMessagePresentableModel *)presentableModel {
    if (presentableModel.isCurrentUser) {
        self.messageLabel.textAlignment = NSTextAlignmentRight;
        self.leftIndicator.hidden = YES;
        self.rightIndicator.hidden = NO;
    }
    else {
        self.messageLabel.textAlignment = NSTextAlignmentLeft;
        self.leftIndicator.hidden = NO;
        self.rightIndicator.hidden = YES;
    }

    self.messageLabel.text = presentableModel.message;
}

@end
