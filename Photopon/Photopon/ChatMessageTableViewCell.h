//
//  ChatMessageTableViewCell.h
//  Photopon
//
//  Created by Hayk Hayotsyan on 9/12/15.
//  Copyright © 2015 Photopon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ChatMessagePresentableModel;

@interface ChatMessageTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@property (weak, nonatomic) IBOutlet UIView *leftIndicator;
@property (weak, nonatomic) IBOutlet UIView *rightIndicator;

-(void)updateWithPresentableModel:(ChatMessagePresentableModel *)presentableModel;

@end
