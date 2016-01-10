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
#import "MiniCouponViewController.h"


@implementation PhotoponCameraView
{
    NSArray* allCoupons;
    NSArray* allPFCoupons;
    NSInteger currentCouponIndex;
    BOOL hasCamera;
    BOOL isInitialized;
    MiniCouponViewController *miniCouponViewController;
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
        self.noCouponView.alpha = 0;
        [self.noCouponIndicator stopAnimating];
    } else {
        
        self.shutterButton.alpha = 0;
        self.noCouponView.alpha = 1;
        [self.noCouponIndicator startAnimating];
        
    }
    
    self.noCouponView.layer.cornerRadius = 10;
    self.noCouponView.layer.masksToBounds = YES;
    
    
    UIImage *iconImage = [[UIImage imageNamed:@"PhotoponOverlayOffer@2x"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [self.couponOverlayGraphics setImage: iconImage];
    

    

    
}


-(void)viewDidLayoutSubviews {
    CGRect tframe = self.topBand.frame;
    tframe.size.height = self.couponOverlayGraphics.frame.origin.y;
    [self.topBand setFrame:tframe];
    
    
    CGRect bframe = self.bottomBand.frame;
    bframe.size.height = [UIScreen mainScreen].bounds.size.height - (self.couponOverlayGraphics.frame.origin.y + self.couponOverlayGraphics.frame.size.height);
    bframe.origin.y = (self.couponOverlayGraphics.frame.origin.y + self.couponOverlayGraphics.frame.size.height);
    [self.bottomBand setFrame:bframe];
    
    
    [self initCamera];

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
        [photoponDrawCtrl setCoupon:[allPFCoupons objectAtIndex: [miniCouponViewController getCouponIndex] ]];
        [photoponDrawCtrl setPhoto:image];
        
        [self.navigationController pushViewController:photoponDrawCtrl animated:true];
        
    }
}


-(void)createMiniCouponView {
 
    
    miniCouponViewController = [[MiniCouponViewController alloc] initWithNibName:@"MiniCouponViewController" bundle:nil];
    [miniCouponViewController setCouponIndex:currentCouponIndex];
    
    const int MiniCouponSize = 92;
    const int MiniCouponViewAlignment = 45;
    
    
    miniCouponViewController.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 60, MiniCouponSize);
    CGPoint ct = self.view.center;
    ct.y = self.couponOverlayGraphics.frame.origin.y + self.couponOverlayGraphics.frame.size.height - MiniCouponSize - MiniCouponViewAlignment;
    miniCouponViewController.view.center = ct;
    
    [self.view addSubview:miniCouponViewController.view];
    [self addChildViewController:miniCouponViewController];
    [miniCouponViewController didMoveToParentViewController:self];
    
}





-(void) initCamera {
    
    if ([allCoupons count] == 0) {
        
        self.shutterButton.alpha = 0;
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
    self.noCouponView.alpha = 0;
    [self.noCouponIndicator stopAnimating];

    [self createMiniCouponView];
    
    
    
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    session.sessionPreset = AVCaptureSessionPresetMedium;
    
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    [captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];

    captureVideoPreviewLayer.frame = [UIScreen mainScreen].bounds;
    [self.imageView setFrame:[UIScreen mainScreen].bounds];
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


@end
