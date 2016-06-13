//
//  ChatPhotoponTableViewCell.h
//  Photopon
//
//  Created by Roman Temchenko on 2016-06-13.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ChatPhotoponPresentableModel;

@interface ChatPhotoponTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *statusLabel;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UIView *containerView;
@property (nonatomic, strong) IBOutlet UIView *leftIndicator;
@property (nonatomic, strong) IBOutlet UIView *rightIndicator;

- (void)updateWithPresentableModel:(ChatPhotoponPresentableModel *)presentableModel;

@end
