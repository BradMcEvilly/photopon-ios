//
//  ChatMessageTableViewCell.h
//  Photopon
//
//  Created by Hayk Hayotsyan on 9/12/15.
//  Copyright © 2015 Photopon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatMessageTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *userLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageText;

@property (weak, nonatomic) IBOutlet UIView *leftIndicator;
@property (weak, nonatomic) IBOutlet UIView *rightIndicator;


-(void)setupCellWithUser:(PFUser*)fromUser withMessages:(NSArray*)messages;


@end
