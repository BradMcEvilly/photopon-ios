//
//  PhotoponCameraView.h
//  Photopon
//
//  Created by Hayk Hayotsyan on 23/8/15.
//  Copyright (c) 2015 Photopon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


@interface PhotoponCameraView : UIViewController<UIGestureRecognizerDelegate>


@property (weak, nonatomic) IBOutlet UIView *imageView;
@property(nonatomic, retain) AVCaptureStillImageOutput *stillImageOutput;

@property (weak, nonatomic) IBOutlet UIImageView *shutterButton;

@property (weak, nonatomic) IBOutlet UIView *miniCouponView;



-(void) setCurrentCouponIndex:(NSInteger)couponIndex;

@end
