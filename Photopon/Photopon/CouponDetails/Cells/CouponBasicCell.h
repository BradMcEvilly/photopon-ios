//
//  CouponBasicCell.h
//  Photopon
//
//  Created by Ante Karin on 09/10/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CouponBasicCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *brandImageView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *addressLabel;

@end
