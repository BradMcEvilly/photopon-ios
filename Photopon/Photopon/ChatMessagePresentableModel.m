//
//  ChatMessagePresentableModel.m
//  Photopon
//
//  Created by Roman Temchenko on 2016-06-10.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import "ChatMessagePresentableModel.h"

@implementation ChatMessagePresentableModel

- (void)appendMessage:(NSString *)message
{
    self.message = [(self.message ?: @"") stringByAppendingFormat:@"\n%@", message];
}

@end
