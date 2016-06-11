//
//  ChatUserTableViewCell.h
//  Photopon
//
//  Created by Roman Temchenko on 2016-06-10.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ChatUserPresentableModel;

@interface ChatUserTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *userLabel;
@property (nonatomic, strong) IBOutlet UIView *leftIndicator;
@property (nonatomic, strong) IBOutlet UIView *rightIndicator;

- (void)updateWithPresentableModel:(ChatUserPresentableModel *)presentableModel;

@end
