//
//  PhotoponCameraView.m
//  Photopon
//
//  Created by Hayk Hayotsyan on 23/8/15.
//  Copyright (c) 2015 Photopon. All rights reserved.
//

#import "PhotoponCameraView.h"
#import "PhotoponDrawController.h"
#import <ImageIO/CGImageProperties.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "Helper.h"


@implementation PhotoponCameraView
{
    NSArray* allCoupons;
    NSArray* allPFCoupons;
    NSInteger currentCouponIndex;
    BOOL hasCamera;
}




-(void) setCurrentCouponIndex:(NSInteger)couponIndex {
    currentCouponIndex = couponIndex;
}



-(void)onShutterTouch {
    [self captureNow];
 
}


-(void)onSwipeLeft:(UISwipeGestureRecognizer *)gestureRecognizer {
    NSLog(@"Swiped left");
    currentCouponIndex = (currentCouponIndex + 1) % [allCoupons count];
    [self createMiniCoupon];
}


-(void)onSwipeRight:(UISwipeGestureRecognizer *)gestureRecognizer {
    NSLog(@"Swiped right");
    currentCouponIndex = (currentCouponIndex - 1 + [allCoupons count]) % [allCoupons count];
    [self createMiniCoupon];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onShutterTouch)];
    singleTap.numberOfTapsRequired = 1;
    [self.shutterButton setUserInteractionEnabled:YES];
    [self.shutterButton addGestureRecognizer:singleTap];
    
    
    [self.miniCouponView setUserInteractionEnabled:YES];
    
    UISwipeGestureRecognizer *swipeRecLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipeLeft:)];
    swipeRecLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.miniCouponView addGestureRecognizer:swipeRecLeft];
    
    UISwipeGestureRecognizer *swipeRecRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipeRight:)];
    swipeRecRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.miniCouponView addGestureRecognizer:swipeRecRight];
    
    
    swipeRecLeft.delegate = self;
    swipeRecRight.delegate = self;
    
    
}



-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        CGPoint touchPoint = [touch locationInView:self.view];
        if (touchPoint.y > 400) {
            return NO;
        }
    }
    return YES;
}




-(IBAction)captureNow {
    
    if (hasCamera) {
        AVCaptureConnection *videoConnection = nil;
        for (AVCaptureConnection *connection in _stillImageOutput.connections)
        {
            for (AVCaptureInputPort *port in [connection inputPorts])
            {
                if ([[port mediaType] isEqual:AVMediaTypeVideo] )
                {
                    videoConnection = connection;
                    break;
                }
            }
            if (videoConnection)
            {
                break;
            }
        }
        
        NSLog(@"about to request a capture from: %@", _stillImageOutput);
        [_stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
         {
             CFDictionaryRef exifAttachments = CMGetAttachment( imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
             if (exifAttachments)
             {
                 // Do something with the attachments.
                 NSLog(@"attachements: %@", exifAttachments);
             } else {
                 NSLog(@"no attachments");
             }
             
             NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
             UIImage *image = [[UIImage alloc] initWithData:imageData];
             
             
             PhotoponDrawController* photoponDrawCtrl = (PhotoponDrawController*)[self.storyboard instantiateViewControllerWithIdentifier:@"SBPhotopon"];
             [photoponDrawCtrl setCoupon:[allPFCoupons objectAtIndex:currentCouponIndex]];
             [photoponDrawCtrl setPhoto:image];
             
             [self.navigationController pushViewController:photoponDrawCtrl animated:true];
             
             //UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
         }];
    } else {
        
        UIImage *image = [UIImage imageNamed:@"camplaceholder.jpg"];
        
        
        PhotoponDrawController* photoponDrawCtrl = (PhotoponDrawController*)[self.storyboard instantiateViewControllerWithIdentifier:@"SBPhotopon"];
        [photoponDrawCtrl setCoupon:[allPFCoupons objectAtIndex:currentCouponIndex]];
        [photoponDrawCtrl setPhoto:image];
        
        [self.navigationController pushViewController:photoponDrawCtrl animated:true];
        
    }
}

-(void)createMiniCoupon {
    NSArray *viewsToRemove = [self.miniCouponView subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
    
    
    NSDictionary* coupon = [allCoupons objectAtIndex:currentCouponIndex];
        
    NSString* title = [coupon objectForKey:@"title"];
    NSString* desc = [coupon objectForKey:@"desc"];
    NSString* pic = [coupon objectForKey:@"pic"];
    
    int width = self.view.bounds.size.width;
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(120, 10, width - 120, 80)];
    titleLabel.text = title;
    titleLabel.numberOfLines = 1;
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;

    
    UILabel *descLabel = [[UILabel alloc]initWithFrame:CGRectMake(120, 100, width - 120, 80)];
    descLabel.text = desc;
    descLabel.numberOfLines = 1;
    descLabel.adjustsFontSizeToFitWidth = YES;
    descLabel.backgroundColor = [UIColor clearColor];
    descLabel.textColor = [UIColor whiteColor];
    descLabel.textAlignment = NSTextAlignmentCenter;
    
    
    
    
    UIImageView* image = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 100, 100)];
    [image sd_setImageWithURL:[NSURL URLWithString:pic] placeholderImage:[UIImage imageNamed:@"couponplaceholder.png"]];
    
    

    [self.miniCouponView addSubview:titleLabel];
    [self.miniCouponView addSubview:image];
}


-(void)viewDidAppear:(BOOL)animated
{
    
    allCoupons = GetNearbyCoupons();
    allPFCoupons = GetNearbyCouponsPF();
    
    
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    session.sessionPreset = AVCaptureSessionPresetMedium;
    
    CALayer *viewLayer = self.imageView.layer;
    
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    
    captureVideoPreviewLayer.frame = self.imageView.bounds;
    [self.imageView.layer addSublayer:captureVideoPreviewLayer];
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (!input) {
        NSLog(@"ERROR: trying to open camera: %@", error);
        hasCamera = NO;
        UIImageView* placeholder = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"camplaceholder.jpg"]];
        placeholder.contentMode = UIViewContentModeScaleAspectFill;
        [placeholder setFrame:self.imageView.frame ];
        [self.imageView addSubview:placeholder];
        
    } else {
        [session addInput:input];
        
        _stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
        [_stillImageOutput setOutputSettings:outputSettings];
        [session addOutput:_stillImageOutput];
        
        [session startRunning];
        hasCamera = YES;
    }
    
    [self createMiniCoupon];
    
    
}


@end
