//
//  PhotoponViewController.h
//  Photopon
//
//  Created by Hayk Hayotsyan on 22/8/15.
//  Copyright (c) 2015 Photopon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoponDrawController : UIViewController

-(void) setCoupon:(NSObject*)coupon;
-(void) setPhoto:(UIImage*)image;

-(void) drawLineFrom:(CGPoint)from to:(CGPoint)to;


@property (weak, nonatomic) IBOutlet UIImageView *tempView;
@property (weak, nonatomic) IBOutlet UIImageView *mainView;
@property (weak, nonatomic) IBOutlet UIImageView *photoView;

@property (weak, nonatomic) IBOutlet UIButton *saveButton;


@property (weak, nonatomic) IBOutlet UIButton *color1;
@property (weak, nonatomic) IBOutlet UIButton *color2;
@property (weak, nonatomic) IBOutlet UIButton *color3;
@property (weak, nonatomic) IBOutlet UIButton *color4;
@property (weak, nonatomic) IBOutlet UIButton *color5;
@property (weak, nonatomic) IBOutlet UIButton *color6;



@property (weak, nonatomic) IBOutlet UIButton *width1;
@property (weak, nonatomic) IBOutlet UIButton *width2;
@property (weak, nonatomic) IBOutlet UIButton *width3;
@property (weak, nonatomic) IBOutlet UIButton *width4;

@end
