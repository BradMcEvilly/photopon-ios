//
//  CouponDefaultCell.h
//  Photopon
//
//  Created by Ante Karin on 14/10/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoundedBorderedView.h"

@interface CouponDefaultCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *expirationLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *brandImageView;
@property (weak, nonatomic) IBOutlet RoundedBorderedView *container;

@end
