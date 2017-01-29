//
//  MessageCell.h
//  Photopon
//
//  Created by Ante Karin on 22/10/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatMessagePresentableModel.h"

@interface MessageCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

- (void)updateWithPresentableModel:(ChatMessagePresentableModel *)presentableModel;

@end
