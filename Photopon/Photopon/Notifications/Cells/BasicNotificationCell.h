//
//  BasicNotificationCell.h
//  Photopon
//
//  Created by Ante Karin on 10/10/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    BasicNotificationCellTemplateAddedYou,
    BasicNotificationCellTemplateRedeemed,
    BasicNotificationCellTemplateMessagedYou,
    BasicNotificationCellTemplateSavedYourPhotopon,
    BasicNotificationCellTemplateUnlockedCoupon,
    BasicNotificationCellTemplateRedeemedUnlockedCoupon
} BasicNotificationCellTemplate;

@interface BasicNotificationCell : UITableViewCell

@property (nonatomic, assign) BasicNotificationCellTemplate templateType;

@property (weak, nonatomic) IBOutlet UIImageView *notificationImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (nonatomic, strong) NSString *user;

- (void)setupCell;

@end
