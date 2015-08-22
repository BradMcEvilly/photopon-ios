//
//  PhotoponViewController.m
//  Photopon
//
//  Created by Hayk Hayotsyan on 22/8/15.
//  Copyright (c) 2015 Photopon. All rights reserved.
//

#import "PhotoponViewController.h"

@implementation PhotoponViewController
{
    NSObject* currentCoupon;
    CGPoint lastPoint;
    bool swiped;
}

-(void) setCoupon:(NSObject*)coupon {
    currentCoupon = coupon;
}


- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    swiped = false;
    UITouch *touch = [[event touchesForView:self.view] anyObject];
    CGPoint location = [touch locationInView:touch.view];
    lastPoint = location;
}



-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    swiped = true;
    UITouch *touch = [[event touchesForView:self.view] anyObject];
    CGPoint location = [touch locationInView:touch.view];
    [self drawLineFrom:lastPoint to:location];
    lastPoint = location;
}



-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event touchesForView:self.view] anyObject];
    CGPoint location = [touch locationInView:touch.view];

    if (swiped) {
        [self drawLineFrom:lastPoint to:location];
    }
    
    
    UIGraphicsBeginImageContext(self.mainView.frame.size);
    [self.mainView.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) blendMode: kCGBlendModeNormal alpha: 1.0];
    [self.tempView.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) blendMode: kCGBlendModeNormal alpha: 1.0];
    
    self.mainView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.tempView.image = nil;


    lastPoint = location;
}





- (void)drawLineFrom:(CGPoint)from to:(CGPoint)to {

    UIGraphicsBeginImageContext(self.view.frame.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [self.tempView.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    
    CGContextMoveToPoint(context, from.x, from.y);
    CGContextAddLineToPoint(context, to.x, to.y);
    
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, 10);
    CGContextSetRGBStrokeColor(context, 1, 0.5, 0.2, 1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    
    CGContextStrokePath(context);

    self.tempView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self drawLineFrom:CGPointMake(0, 0) to:CGPointMake(100, 100) ];
    
    
    
}

@end
