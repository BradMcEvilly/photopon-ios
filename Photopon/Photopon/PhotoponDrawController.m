//
//  PhotoponViewController.m
//  Photopon
//
//  Created by Hayk Hayotsyan on 22/8/15.
//  Copyright (c) 2015 Photopon. All rights reserved.
//

#import "PhotoponDrawController.h"
#import "PhotoponCameraView.h"
#import "FriendsViewController.h"
#import "DBAccess.h"
@import Foundation;


@implementation PhotoponDrawController
{
    PFObject* currentCoupon;
    CGPoint lastPoint;
    bool swiped;
    UIImage* photo;
    int numSuccess;
    
    PFFile* photoFile;
    PFFile* drawingFile;
    
    UIColor* selectedColor;
    NSInteger selectedWidth;
    
    
    NSArray* widthSizes;
}

-(void) setCoupon:(PFObject*)coupon {
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
    CGContextSetLineWidth(context, selectedWidth + 1);
    
    CGFloat redColor, greenColor, blueColor, colorAlpha;
    
    [selectedColor getRed:&redColor green:&greenColor blue:&blueColor alpha:&colorAlpha];
    
    CGContextSetRGBStrokeColor(context, redColor, greenColor, blueColor, colorAlpha);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    
    CGContextStrokePath(context);

    self.tempView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}


-(void)sendPhotopons:(NSArray*)users {
    
    
    if (drawingFile == NULL) {
        drawingFile = [NSNull null];
    }
    
    
    PFObject* newPhotoponObject = [PFObject objectWithClassName:@"Photopon"];
    [newPhotoponObject setObject:drawingFile forKey:@"drawing"];
    [newPhotoponObject setObject:photoFile forKey:@"photo"];
    [newPhotoponObject setObject:currentCoupon forKey:@"coupon"];
    [newPhotoponObject setObject:[PFUser currentUser] forKey:@"creator"];

    [newPhotoponObject setObject:users forKey:@"users"];


    
    [newPhotoponObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            photoFile = NULL;
            drawingFile = NULL;
            
            [self.navigationController popToRootViewControllerAnimated:YES];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Photopon"
                message:@"Photopon was saved successfully."
                delegate:nil
                cancelButtonTitle:@"OK"
                otherButtonTitles:nil];
            
            [alert show];
            
            for (int i = 0; i < [users count]; ++i) {
                PFUser* user = [PFQuery getUserObjectWithId:users[i] ];
                CreatePhotoponNotification(user, newPhotoponObject);
            }
            [currentCoupon incrementKey:@"numShared" byAmount:[NSNumber numberWithUnsignedLong:[users count] ] ];
            [currentCoupon saveInBackground];


            
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
}


-(void)savePhotopon {

    FriendsViewController* friendsViewController = (FriendsViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"SBFriends"];
    [friendsViewController friendSelectedCallBack:@selector(sendPhotopons:) target:self];
    [self.navigationController pushViewController:friendsViewController animated:true];

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


-(void)selectColor: (UIColor*)color {
    selectedColor = color;
    self.chooseColor.backgroundColor = color;
    self.colorBox.hidden = YES;
}

-(void)selectWidth: (NSInteger)width {
    selectedWidth = width;
    NSInteger w = [widthSizes[width] integerValue];
    
    CGRect oldFrame = self.widthDisplay.frame;
    
    oldFrame.size = CGSizeMake(w, w);
    [self.widthDisplay setFrame:oldFrame];
    
    self.widthDisplay.layer.cornerRadius = w / 2;
    self.widthDisplay.center = self.chooseWidth.center;
    self.widthBox.hidden = YES;
}






-(void)onColorChange: (id)sender {
    UIButton* btn = (UIButton*)sender;
    [self selectColor: btn.backgroundColor];
}


-(void)onWidthChange: (id)sender {
    UIButton* btn = (UIButton*)sender;
    [self selectWidth:btn.tag];
}







-(void)toggleColorBox {
    self.colorBox.hidden = !self.colorBox.hidden;
}

-(void)toggleWidthBox {
    self.widthBox.hidden = !self.widthBox.hidden;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.photoView setImage:photo];
    
    
    photoFile = [NSNull null];
    drawingFile = [NSNull null];
    
    widthSizes = @[@10, @20, @30, @40];
    
    [self.saveButton addTarget:self action:@selector(onSaveTouch) forControlEvents:UIControlEventTouchDown];
    
    
    [self.chooseColor addTarget:self action:@selector(toggleColorBox) forControlEvents:UIControlEventTouchDown];
    [self.chooseWidth addTarget:self action:@selector(toggleWidthBox) forControlEvents:UIControlEventTouchDown];
    
    for (UIButton* btn in self.colors) {
        [btn addTarget:self action:@selector(onColorChange:) forControlEvents:UIControlEventTouchDown];
    }
    
    
    for (UIView* d in self.disableInteraction) {
        d.userInteractionEnabled = NO;
    }
 
    
    [self.width1 addTarget:self action:@selector(onWidthChange:) forControlEvents:UIControlEventTouchDown];
    [self.width2 addTarget:self action:@selector(onWidthChange:) forControlEvents:UIControlEventTouchDown];
    [self.width3 addTarget:self action:@selector(onWidthChange:) forControlEvents:UIControlEventTouchDown];
    [self.width4 addTarget:self action:@selector(onWidthChange:) forControlEvents:UIControlEventTouchDown];
    
    [self selectColor:((UIButton*)self.colors[0]).backgroundColor];
}

-(void)viewDidAppear:(BOOL)animated {
    [self selectWidth:1];
}

-(void)viewWillAppear:(BOOL)animated {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"PhotoponDrawScreen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
}



@end
