//
//  ChatMessagePresentableModel.h
//  Photopon
//
//  Created by Roman Temchenko on 2016-06-10.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import "ChatBasePresentableModel.h"

@interface ChatMessagePresentableModel : ChatBasePresentableModel

@property (nonatomic, copy) NSString *message;

- (void)appendMessage:(NSString *)message;

@end
