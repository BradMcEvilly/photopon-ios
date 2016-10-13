//
//  BasicNotificationCell.m
//  Photopon
//
//  Created by Ante Karin on 10/10/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import "BasicNotificationCell.h"
#import "UIColor+Convinience.h"

@interface BasicNotificationCell()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *interLabelSpacingConstraint;

@end

@implementation BasicNotificationCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.notificationImageView.layer.cornerRadius = 22;
    self.notificationImageView.layer.masksToBounds = YES;
}

- (NSAttributedString *)attributedStringForUser:(NSString *)user cellTemplate:(BasicNotificationCellTemplate)template {
    UIFont *font = [UIFont fontWithName:@"Montserrat-Regular" size:16.0];
    UIColor *userTextColor = [UIColor colorWithHexString:@"#595747" alpha:1.0];
    UIColor *highlightedTextColor = [UIColor colorWithHexString:@"#D94CCB" alpha:1.0];

    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc]initWithString:user attributes:@{NSFontAttributeName: font, NSForegroundColorAttributeName: userTextColor}];
    [attrString appendAttributedString:[[NSAttributedString alloc]initWithString:@" "]];

    NSString *highlightedText;

    switch (self.templateType) {
        case BasicNotificationCellTemplateAddedYou:
            highlightedText = @"added you";
            break;
        case BasicNotificationCellTemplateRedeemed:
            highlightedText = @"redeemed your Photopon";
            break;
        case BasicNotificationCellTemplateMessagedYou:
            highlightedText = @"messaged you";
            break;
        case  BasicNotificationCellTemplateSavedYourPhotopon:
            highlightedText = @"saved your Photopon";
            break;
        default:
            break;
    }

    NSAttributedString *highlightedString = [[NSAttributedString alloc]initWithString:highlightedText    attributes:@{NSFontAttributeName: font, NSForegroundColorAttributeName: highlightedTextColor}];
    [attrString appendAttributedString:highlightedString];

    return attrString;
}

- (void)setupCell {
    (self.subtitleLabel.text.length > 0) ? (self.interLabelSpacingConstraint.constant = 5) : (self.interLabelSpacingConstraint.constant = 0);
    if (self.user) {
        self.titleLabel.attributedText = [self attributedStringForUser:self.user cellTemplate:self.templateType];
    }
}

@end
