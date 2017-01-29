//
//  SentCouponCell.h
//  Photopon
//
//  Created by Ante Karin on 10/10/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoundedBorderedView.h"

@interface SentCouponCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *couponImageView;
@property (weak, nonatomic) IBOutlet UILabel *couponTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *couponSubtitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *couponExpiryLabel;
@property (weak, nonatomic) IBOutlet RoundedBorderedView *couponContainerView;

@end
