//
//  FriendTableViewCell.h
//  Photopon
//
//  Created by Ante Karin on 15/10/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *friendImageView;
@property (weak, nonatomic) IBOutlet UILabel *friendUsernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *friendShareInfoLabel;

- (void)setName:(NSString *)name username:(NSString *)username;
- (void)setNumberOfGiftsUsed:(NSInteger)giftsUsed giftsShared:(NSInteger)giftsShare;

@end
