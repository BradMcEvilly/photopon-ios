//
//  LocationCell.h
//  Photopon
//
//  Created by Ante Karin on 21/07/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocationCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UILabel *iconLabel;

@end
