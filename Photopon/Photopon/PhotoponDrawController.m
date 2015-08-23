//
//  PhotoponViewController.m
//  Photopon
//
//  Created by Hayk Hayotsyan on 22/8/15.
//  Copyright (c) 2015 Photopon. All rights reserved.
//

#import "PhotoponDrawController.h"
#import "PhotoponCameraView.h"
#import "DBAccess.h"


@implementation PhotoponDrawController
{
    NSObject* currentCoupon;
    CGPoint lastPoint;
    bool swiped;
    UIImage* photo;
    int numSuccess;
    
    PFFile* photoFile;
    PFFile* drawingFile;
}

-(void) setCoupon:(NSObject*)coupon {
    currentCoupon = coupon;
}


-(void) setPhoto:(UIImage*)image {
    photo = image;
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
    
    
    UIGraphicsBeginImageContext(self.view.frame.size);
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
    CGContextSetLineWidth(context, 3);
    CGContextSetRGBStrokeColor(context, 1, 0.5, 0.2, 1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    
    CGContextStrokePath(context);

    self.tempView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

-(void)savePhotopon {
    PFObject* newPhotoponObject = [PFObject objectWithClassName:@"Photopon"];
    [newPhotoponObject setObject:drawingFile forKey:@"drawing"];
    [newPhotoponObject setObject:photoFile forKey:@"photo"];
    
    [newPhotoponObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            drawingFile = nil;
            photoFile = nil;
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Photopon"
                                                            message:@"Photopon was saved successfully."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];

        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

-(void)onSaveTouch {
    numSuccess = 0;
    
    SaveImage(@"photo.jpg", self.photoView.image, ^(PFFile* file, NSError *error) {
        numSuccess++;
        photoFile = file;
        
        if (numSuccess == 2) {
            [self savePhotopon];
        }
    });
    SaveImage(@"drawing.png", self.mainView.image, ^(PFFile* file, NSError *error) {
        numSuccess++;
        drawingFile = file;
        
        if (numSuccess == 2) {
            [self savePhotopon];
        }
    });
    
    
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.photoView setImage:photo];
    
    
    
    
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSaveTouch)];
    singleTap.numberOfTapsRequired = 1;
    [self.saveButton setUserInteractionEnabled:YES];
    [self.saveButton addGestureRecognizer:singleTap];

    
    
    //PhotoponCameraView* camView = (PhotoponCameraView*)[self.storyboard instantiateViewControllerWithIdentifier:@"SBPhotoponCam"];
    //[self showViewController:camView sender:nil];
    
    
    
}

@end
