//
//  PhotoponCameraView.h
//  Photopon
//
//  Created by Hayk Hayotsyan on 23/8/15.
//  Copyright (c) 2015 Photopon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "MiniCouponView.h"
#import "Helper.h"

@interface PhotoponCameraView : UIViewController<CouponUpdateDelegate>


@property (weak, nonatomic) IBOutlet UIView *imageView;
@property(nonatomic, retain) AVCaptureStillImageOutput *stillImageOutput;

@property (weak, nonatomic) IBOutlet UIImageView *shutterButton;
@property (weak, nonatomic) IBOutlet UIView *noCouponView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *noCouponIndicator;



-(void) setCurrentCouponIndex:(NSInteger)couponIndex;

@end
