//
//  ChatMessageView.m
//  Photopon
//
//  Created by Hayk Hayotsyan on 20/8/15.
//  Copyright (c) 2015 Photopon. All rights reserved.
//

#import "ChatMessageView.h"

@implementation ChatMessageView



-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if(self)
    {
        [self initViews];
        [self initConstraints];
    }
    
    return self;
}

-(void)initViews
{
    self.backgroundColor = [UIColor clearColor];
    
    self.leftImage = [[UIImageView alloc] init];
    self.leftImage.contentMode = UIViewContentModeScaleAspectFill;
    self.leftImage.clipsToBounds = YES;
    self.leftImage.layer.cornerRadius = 10.0;
    
    self.textLabel = [[UILabel alloc] init];
    self.textLabel.numberOfLines = 0;
    self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    self.rightImage = [[UIImageView alloc] init];
    self.rightImage.contentMode = UIViewContentModeScaleAspectFill;
    self.rightImage.layer.cornerRadius = 10.0;
    self.rightImage.clipsToBounds = YES;
    
    [self addSubview:self.leftImage];
    [self addSubview:self.textLabel];
    [self addSubview:self.rightImage];
}

-(void)initConstraints
{
    self.leftImage.translatesAutoresizingMaskIntoConstraints = NO;
    self.textLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.rightImage.translatesAutoresizingMaskIntoConstraints = NO;
    
    id views = @{
                 @"leftImage": self.leftImage,
                 @"textLabel": self.textLabel,
                 @"rightImage": self.rightImage
                 };
    
    // horizontal constraints
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[leftImage(20)]-10-[textLabel]-[rightImage(20)]-10-|" options:0 metrics:nil views:views]];
    
    // vertical constraints
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.leftImage attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.textLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.rightImage attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[leftImage(20)]" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[rightImage(20)]" options:0 metrics:nil views:views]];
}
@end

