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



@property (weak, nonatomic) IBOutlet UIView *widthBox;
@property (weak, nonatomic) IBOutlet UIView *colorBox;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *colors;



@property (weak, nonatomic) IBOutlet UIButton *chooseColor;
@property (weak, nonatomic) IBOutlet UIButton *chooseWidth;

@property (weak, nonatomic) IBOutlet UIButton *width1;
@property (weak, nonatomic) IBOutlet UIButton *width2;
@property (weak, nonatomic) IBOutlet UIButton *width3;
@property (weak, nonatomic) IBOutlet UIButton *width4;


@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *disableInteraction;



@property (weak, nonatomic) IBOutlet UIView *widthDisplay;

@end
