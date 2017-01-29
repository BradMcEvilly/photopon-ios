//
//  MessageCell.m
//  Photopon
//
//  Created by Ante Karin on 22/10/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import "MessageCell.h"

@implementation MessageCell

- (void)updateWithPresentableModel:(ChatMessagePresentableModel *)presentableModel {
    self.messageLabel.text = presentableModel.message;
}

@end
