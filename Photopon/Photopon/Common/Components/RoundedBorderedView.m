//
//  RoundedBorderedView.m
//  Photopon
//
//  Created by Ante Karin on 02/10/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import "RoundedBorderedView.h"

@interface RoundedBorderedView()

@property (nonatomic, weak) CAShapeLayer *borderLayer;

@end

@implementation RoundedBorderedView

- (void)roundCorners {
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                   byRoundingCorners:self.corners
                                                         cornerRadii:CGSizeMake(12.0, 12.0)];

    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
}

- (void)addBorder {
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                   byRoundingCorners:self.corners
                                                         cornerRadii:CGSizeMake(12.0, 12.0)];


    CAShapeLayer *frameLayer = [CAShapeLayer layer];
    frameLayer.frame = self.bounds;
    frameLayer.path = maskPath.CGPath;
    frameLayer.strokeColor = self.borderColor.CGColor;
    frameLayer.fillColor = nil;

    [self.borderLayer removeFromSuperlayer];
    self.borderLayer = frameLayer;
    [self.layer addSublayer:self.borderLayer];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    [self roundCorners];
    [self addBorder];
}

@end
