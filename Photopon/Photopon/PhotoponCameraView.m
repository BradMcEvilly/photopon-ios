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
    MiniCouponViewController *miniCouponViewController;
    
    MainController* parentCtrl;
    
    AVCaptureDevicePosition activeDevice;
    
    NSString* selectedFriendId;
}




-(void) setCurrentCouponIndex:(NSInteger)couponIndex {
    currentCouponIndex = couponIndex;
    if (miniCouponViewController) {
        [miniCouponViewController setCouponIndex:currentCouponIndex];
    }
}

-(void) setSelectedFriend:(NSString*)friendId {
    selectedFriendId = friendId;
}


-(void)onShutterTouch {
    SendGAEvent(@"user_action", @"photopon_camera", @"capture_clicked");
    [self captureNow];
 
}


-(void)maybeShowNoCoupons {
    BOOL hasCoupons = ([allCoupons count] > 0);
    
    
    self.shutterButton.hidden = !hasCoupons;
    self.noCouponView.hidden = hasCoupons;
    
    if (hasCoupons) {
        [self.noCouponIndicator stopAnimating];
    } else {
        [self.noCouponIndicator startAnimating];
    }

}

- (void) couponsUpdated {
    allCoupons = GetNearbyCoupons();
    allPFCoupons = GetNearbyCouponsPF();
    
    
    [miniCouponViewController couponsUpdated];
    [self maybeShowNoCoupons];
}


-(void)dealloc {
    RemoveCouponUpdateListener(self);
}

-(void)setPageViewController:(MainController*)parent {
    parentCtrl = parent;
}


-(void)onSwitchCamera {
    if (activeDevice == AVCaptureDevicePositionFront) {
        activeDevice = AVCaptureDevicePositionBack;
    } else {
        activeDevice = AVCaptureDevicePositionFront;
    }
    [self initCamera];
    
    SendGAEvent(@"user_action", @"photopon_camera", @"switch_clicked");
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
    
    
    
    UITapGestureRecognizer *switchButtonTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSwitchCamera)];
    switchButtonTap.numberOfTapsRequired = 1;
    [self.switchCameraButton setUserInteractionEnabled:YES];
    [self.switchCameraButton addGestureRecognizer:switchButtonTap];
    
    
    self.noCouponView.layer.cornerRadius = 10;
    self.noCouponView.layer.masksToBounds = YES;
    
    
    UIImage *iconImage = [[UIImage imageNamed:@"PhotoponOverlayOffer@2x"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [self.couponOverlayGraphics setImage: iconImage];

    
    activeDevice = AVCaptureDevicePositionBack;
    if ([self getCameraWithType:AVCaptureDevicePositionFront] == nil) {
        self.switchCameraButton.hidden = YES;
    }
    
    
    [self initCamera];
    [self maybeShowNoCoupons];
    [self createMiniCouponView];

    
}

-(void)closeView {
    if (parentCtrl) {
        [parentCtrl gotoNotificationView];
        
    }
    [self dismissViewControllerAnimated:TRUE completion:nil];
}

-(void)viewDidLayoutSubviews {
    CGRect tframe = self.topBand.frame;
    tframe.size.height = self.couponOverlayGraphics.frame.origin.y;
    [self.topBand setFrame:tframe];
    
    
    CGRect bframe = self.bottomBand.frame;
    bframe.size.height = [UIScreen mainScreen].bounds.size.height - (self.couponOverlayGraphics.frame.origin.y + self.couponOverlayGraphics.frame.size.height);
    bframe.origin.y = (self.couponOverlayGraphics.frame.origin.y + self.couponOverlayGraphics.frame.size.height);
    [self.bottomBand setFrame:bframe];
    
    

}



-(void)viewWillAppear:(BOOL)animated {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"PhotoponCameraScreen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    
    
}


-(void)viewDidAppear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
}

-(void)viewDidDisappear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
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
             
             if (activeDevice == AVCaptureDevicePositionFront) {
                 image = [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:UIImageOrientationLeftMirrored];
             }
             
             
             PhotoponDrawController* photoponDrawCtrl = (PhotoponDrawController*)[self.storyboard instantiateViewControllerWithIdentifier:@"SBPhotopon"];
             [photoponDrawCtrl setCoupon:[allPFCoupons objectAtIndex:[miniCouponViewController getCouponIndex]] withIndex:[miniCouponViewController getCouponIndex]];
             [photoponDrawCtrl setPhoto:image];
             
             [photoponDrawCtrl setSelectedFriend:selectedFriendId];
             
             [photoponDrawCtrl setPageViewController:parentCtrl];
             
             [self presentViewController:photoponDrawCtrl animated:true completion:nil];
             
             //UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
         }];
    } else {
        
        UIImage *image = [UIImage imageNamed:@"camplaceholder.jpg"];
        
        
        PhotoponDrawController* photoponDrawCtrl = (PhotoponDrawController*)[self.storyboard instantiateViewControllerWithIdentifier:@"SBPhotopon"];
        [photoponDrawCtrl setCoupon:[allPFCoupons objectAtIndex: [miniCouponViewController getCouponIndex] ] withIndex: [miniCouponViewController getCouponIndex] ];
        [photoponDrawCtrl setPhoto:image];
        
        
        [photoponDrawCtrl setSelectedFriend:selectedFriendId];
        
        [photoponDrawCtrl setPageViewController:parentCtrl];
        
        [self presentViewController:photoponDrawCtrl animated:true completion:nil];
    }
    

}


-(void)createMiniCouponView {
 
    
    miniCouponViewController = [[MiniCouponViewController alloc] initWithNibName:@"MiniCouponViewController" bundle:nil];
    [miniCouponViewController setCouponIndex:currentCouponIndex];
    
    const int MiniCouponSize = 92;
    
    
    miniCouponViewController.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width * 0.88, MiniCouponSize);
    CGPoint ct = self.view.center;
    ct.y = 80 + [UIScreen mainScreen].bounds.size.width * 0.9 - MiniCouponSize / 2;
    miniCouponViewController.view.center = ct;
    
    [self.view addSubview:miniCouponViewController.view];
    [self addChildViewController:miniCouponViewController];
    [miniCouponViewController didMoveToParentViewController:self];
    
}



-(AVCaptureDevice*)getCameraWithType: (AVCaptureDevicePosition)cameraType
{
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];

    for (AVCaptureDevice *device in videoDevices) {
        if (device.position == cameraType) {
            return device;
        }
    }
    
    return nil;
}


-(void) initCamera {
    
    
    
    
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    session.sessionPreset = AVCaptureSessionPresetMedium;
    
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    [captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];

    captureVideoPreviewLayer.frame = [UIScreen mainScreen].bounds;
    [self.imageView setFrame:[UIScreen mainScreen].bounds];
    [self.imageView.layer addSublayer:captureVideoPreviewLayer];
    
    
    
    AVCaptureDevice *device = [self getCameraWithType: activeDevice];
    
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
