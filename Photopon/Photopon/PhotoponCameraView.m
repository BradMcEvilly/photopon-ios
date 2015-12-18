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
    BOOL isInitialized;
}




-(void) setCurrentCouponIndex:(NSInteger)couponIndex {
    currentCouponIndex = couponIndex;
}



-(void)onShutterTouch {
    [self captureNow];
 
}



- (void) couponsUpdated {
    allCoupons = GetNearbyCoupons();
    allPFCoupons = GetNearbyCouponsPF();
    [self initCamera];
}



-(void)dealloc {
    RemoveCouponUpdateListener(self);
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    allCoupons = GetNearbyCoupons();
    allPFCoupons = GetNearbyCouponsPF();
    
    AddCouponUpdateListener(self);

    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onShutterTouch)];
    singleTap.numberOfTapsRequired = 1;
    [self.shutterButton setUserInteractionEnabled:YES];
    [self.shutterButton addGestureRecognizer:singleTap];

    
    if ([allCoupons count] != 0) {
        self.shutterButton.alpha = 1;
        self.miniCouponView.alpha = 1;
        self.noCouponView.alpha = 0;
        [self.noCouponIndicator stopAnimating];
    } else {
        
        self.shutterButton.alpha = 0;
        self.miniCouponView.alpha = 0;
        self.noCouponView.alpha = 1;
        [self.noCouponIndicator startAnimating];
        
    }
    
    self.noCouponView.layer.cornerRadius = 10;
    self.noCouponView.layer.masksToBounds = YES;
    
}




-(void)viewWillAppear:(BOOL)animated {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"PhotoponCameraScreen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
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

-(void) initCamera {
    
    if ([allCoupons count] == 0) {
        
        self.shutterButton.alpha = 0;
        self.miniCouponView.alpha = 0;
        self.noCouponView.alpha = 1;
        [self.noCouponIndicator startAnimating];
        
        isInitialized = NO;
        return;
    }

    if (isInitialized) {
        return;
    }
    
    isInitialized = YES;
    
    self.shutterButton.alpha = 1;
    self.miniCouponView.alpha = 1;
    self.noCouponView.alpha = 0;
    [self.noCouponIndicator stopAnimating];

    
    [self.miniCouponView initView: currentCouponIndex];
    
    
    
    
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    session.sessionPreset = AVCaptureSessionPresetMedium;
    
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

}



-(void)viewDidAppear:(BOOL)animated {
    [self initCamera];
    
}


@end
