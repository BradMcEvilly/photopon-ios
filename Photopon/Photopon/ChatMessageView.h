//
//  ChatMessageView.h
//  Photopon
//
//  Created by Hayk Hayotsyan on 20/8/15.
//  Copyright (c) 2015 Photopon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatMessageView : UIView

@property (nonatomic, strong) UIImageView *leftImage;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UIImageView *rightImage;

@end