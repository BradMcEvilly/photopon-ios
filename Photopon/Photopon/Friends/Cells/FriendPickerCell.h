//
//  FriendPickerCell.h
//  Photopon
//
//  Created by Ante Karin on 23/10/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendPickerCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userAvatarImageView;
@property (weak, nonatomic) IBOutlet UIImageView *selectionImageView;

@property (nonatomic, assign) BOOL friendSelected;

- (void)setSelecteState;
- (void)setDeselectedState;

@end
