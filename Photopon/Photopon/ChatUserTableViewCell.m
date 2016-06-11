//
//  ChatUserTableViewCell.m
//  Photopon
//
//  Created by Roman Temchenko on 2016-06-10.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import "ChatUserTableViewCell.h"
#import "ChatUserPresentableModel.h"

@implementation ChatUserTableViewCell

- (void)updateWithPresentableModel:(ChatUserPresentableModel *)presentableModel
{
    if (presentableModel.isCurrentUser) {
        self.userLabel.textAlignment = NSTextAlignmentRight;
        self.leftIndicator.hidden = YES;
        self.rightIndicator.hidden = NO;
    }
    else {
        self.userLabel.textAlignment = NSTextAlignmentLeft;
        self.leftIndicator.hidden = NO;
        self.rightIndicator.hidden = YES;
    }
    
    self.userLabel.text = presentableModel.userName;
}

@end
