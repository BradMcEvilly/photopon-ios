//
//  ChatMessageTableViewCell.m
//  Photopon
//
//  Created by Hayk Hayotsyan on 9/12/15.
//  Copyright © 2015 Photopon. All rights reserved.
//
#import <Parse/Parse.h>
#import "ChatMessageTableViewCell.h"

@implementation ChatMessageTableViewCell

- (void)awakeFromNib {
    [self.messageText setPreferredMaxLayoutWidth:[UIScreen mainScreen].bounds.size.width - 20];
}

-(void)setupCellWithUser:(PFUser*)fromUser withMessages:(NSArray*)messages {
    BOOL isMyMessage = [[fromUser objectId] isEqualToString:[[PFUser currentUser] objectId]];
    
    if (isMyMessage) {
        self.messageText.textAlignment = NSTextAlignmentRight;
        self.userLabel.textAlignment = NSTextAlignmentRight;
        self.leftIndicator.alpha = 0;
        self.rightIndicator.alpha = 1;
    } else {
        
        self.messageText.textAlignment = NSTextAlignmentLeft;
        self.userLabel.textAlignment = NSTextAlignmentLeft;
        self.leftIndicator.alpha = 1;
        self.rightIndicator.alpha = 0;
    }


    NSString* str = @"";
    if ([messages count]) {
        str = messages[0];
    }
    
    for (int i = 1; i < [messages count]; ++i) {
        str = [NSString stringWithFormat:@"%@\n%@",str,messages[i]];
    }
    
    self.messageText.text = str;
    self.userLabel.text = [fromUser username];
}

@end
