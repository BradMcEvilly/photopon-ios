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


@implementation PhotoponCameraView
{
    NSMutableArray* allCoupons;
    NSInteger currentCouponIndex;
}



-(void) setCoupons:(NSMutableArray*)coupons {
    allCoupons = coupons;
}


-(void) setCurrentCouponIndex:(NSInteger)couponIndex {
    currentCouponIndex = couponIndex;
}



-(void)onShutterTouch {
    [self captureNow];
 
}


-(void)viewDidLoad
{
    [super viewDidLoad];
    
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onShutterTouch)];
    singleTap.numberOfTapsRequired = 1;
    [self.shutterButton setUserInteractionEnabled:YES];
    [self.shutterButton addGestureRecognizer:singleTap];
    
    
}


-(IBAction)captureNow {
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
         [photoponDrawCtrl setCoupon:[allCoupons objectAtIndex:currentCouponIndex]];
         [photoponDrawCtrl setPhoto:image];
         
         [self.navigationController pushViewController:photoponDrawCtrl animated:true];
         
         //UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
     }];
}

-(void)viewDidAppear:(BOOL)animated
{
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    session.sessionPreset = AVCaptureSessionPresetMedium;
    
    CALayer *viewLayer = self.imageView.layer;
    NSLog(@"viewLayer = %@", viewLayer);
    
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    
    captureVideoPreviewLayer.frame = self.imageView.bounds;
    [self.imageView.layer addSublayer:captureVideoPreviewLayer];
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (!input) {
        // Handle the error appropriately.
        NSLog(@"ERROR: trying to open camera: %@", error);
    }
    [session addInput:input];
    
    _stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [_stillImageOutput setOutputSettings:outputSettings];
    [session addOutput:_stillImageOutput];
    
    [session startRunning];
}


@end
