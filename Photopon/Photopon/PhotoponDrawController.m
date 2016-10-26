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
#import "MiniCouponViewController.h"
#import "IndicatorViewController.h"
#import "AlertBox.h"
#import "TooltipFactory.h"
#import "UIView+CommonLayout.h"
#import "FriendsPickerTableViewController.h"

@import Foundation;

@interface PhotoponDrawController() <FriendsPickerDelegate>

@property (nonatomic, strong) AMPopTip *tooltip;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *photoponContainerView;

@end

@implementation PhotoponDrawController
{
    PFObject* currentCoupon;
    NSInteger currentCouponIndex;
    CGPoint lastPoint;
    bool swiped;
    UIImage* photo;
    int numSuccess;
    
    PFFile* photoFile;
    PFFile* drawingFile;
    
    UIColor* selectedColor;
    NSInteger selectedWidth;
    
    MainController* parentCtrl;

    NSArray* widthSizes;
    
    NSString* selectedFriendId;
    
    MiniCouponViewController* miniCouponViewController;
}


-(void)setPageViewController:(MainController*)parent {
    parentCtrl = parent;
}


-(void) setCoupon:(PFObject*)coupon withIndex:(NSInteger)index {
    currentCoupon = coupon;
    currentCouponIndex = index;
}


-(void) setPhoto:(UIImage*)image {
    photo = image;
}


-(void) setSelectedFriend:(NSString*)friendId {
    selectedFriendId = friendId;
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




-(void)createMiniCouponView {
    miniCouponViewController = [[MiniCouponViewController alloc] initWithNibName:@"MiniCouponViewController" bundle:nil];
    [miniCouponViewController setCouponIndex:currentCouponIndex];

    [self.photoponContainerView.contentView addSubviewAndFill:miniCouponViewController.view];
    [self addChildViewController:miniCouponViewController];
    [miniCouponViewController didMoveToParentViewController:self];
}

-(void)sendPhotopons:(NSArray*)users {
    if (drawingFile == NULL) {
        drawingFile = [NSNull null];
    }
    
    NSMutableArray* userIds = [NSMutableArray new];
    for (PFObject* user in users) {
        [userIds addObject:[user objectId]];
    }

    PFObject* newPhotoponObject = [PFObject objectWithClassName:@"Photopon"];
    [newPhotoponObject setObject:drawingFile forKey:@"drawing"];
    [newPhotoponObject setObject:photoFile forKey:@"photo"];
    [newPhotoponObject setObject:[miniCouponViewController getCoupon] forKey:@"coupon"];
    [newPhotoponObject setObject:[PFUser currentUser] forKey:@"creator"];
    [newPhotoponObject setObject:userIds forKey:@"users"];
    
    [newPhotoponObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            SendGAEvent(@"user_action", @"photopon_draw", @"photopon_sent");
            photoFile = NULL;
            drawingFile = NULL;
            
            for (int i = 0; i < [users count]; ++i) {
                PFUser* user = users[i];
                CreatePhotoponNotification(user, newPhotoponObject);
            }
            [currentCoupon incrementKey:@"numShared" byAmount:[NSNumber numberWithUnsignedLong:[users count] ] ];
            [currentCoupon saveInBackground];

            [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
                [AlertBox showMessageFor:self
                               withTitle:@"Photopon"
                             withMessage:@"Photopon was saved successfully"
                              leftButton:nil
                             rightButton:@"OK"
                              leftAction:nil
                             rightAction:nil];
            }];

            
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
}


-(void)savePhotopon {
    if (selectedFriendId) {
        [self sendPhotopons:@[selectedFriendId]];
    } else {
        
        PFUser* user = [PFUser currentUser];
        
        PFQuery *query = [PFQuery queryWithClassName:@"PerUserShare"];
        [query includeKey:@"user"];
        [query includeKey:@"coupon"];
        [query includeKey:@"friend"];
        
        [query whereKey:@"user" equalTo:user];
        [query whereKey:@"coupon" equalTo:[miniCouponViewController getCoupon]];
        
        
        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            NSMutableArray* excludeFriends = [NSMutableArray new];
            
            for (PFObject* obj in objects) {
                [excludeFriends addObject:[obj valueForKey:@"friend"]];
            }

            FriendsPickerTableViewController *pickerVC = [[UIStoryboard storyboardWithName:@"Friends" bundle:nil] instantiateViewControllerWithIdentifier:@"FriendsPickerTableViewController"];
            pickerVC.excludedFriends = [excludeFriends mutableCopy];
            pickerVC.delegate = self;
            [self presentViewController:[pickerVC setupDefaultNavController] animated:YES completion:nil];
//
//            FriendsViewController* friendsViewController = (FriendsViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"SBFriends"];
//            [friendsViewController excludeFriends:excludeFriends];
//            [friendsViewController friendSelectedCallBack:@selector(sendPhotopons:) target:self];
//            [self presentViewController:friendsViewController animated:true completion:nil];

        }];
        
        
    }
}

-(void)onSaveTouch {
    numSuccess = 0;
    SendGAEvent(@"user_action", @"photopon_camera", @"upload_pics");
    IndicatorViewController* ind = [IndicatorViewController showIndicator:self withText:@"Uploading Photopon..." timeout:150 withDelay:0.5];

    [TooltipFactory setPersonalizeTooltipChecked];
    [self.tooltip hide];
    
    if (self.photoView.image == nil) {
        numSuccess++;
    } else {
        SaveImage(@"photo.jpg", self.photoView.image, ^(PFFile* file, NSError *error) {
            numSuccess++;
            photoFile = file;
            
            if (numSuccess == 2) {
                [ind hide];
                [self savePhotopon];
            }
        });
    }
    
    
    if (self.mainView.image == nil) {
        numSuccess++;
    } else {
        SaveImage(@"drawing.png", self.mainView.image, ^(PFFile* file, NSError *error) {
            numSuccess++;
            drawingFile = file;
            
            if (numSuccess == 2) {
                [ind hide];
                [self savePhotopon];
            }
        });
    }
    
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
    SendGAEvent(@"user_action", @"photopon_camera", @"color_change");
    [self selectColor: btn.backgroundColor];
}


-(void)onWidthChange: (id)sender {
    UIButton* btn = (UIButton*)sender;
    SendGAEvent(@"user_action", @"photopon_camera", @"width_change");
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
    

    self.photoponContainerView.layer.cornerRadius = 10;
    self.photoponContainerView.layer.masksToBounds = YES;
    self.photoponContainerView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];

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
    
    [self createMiniCouponView];

    
    UITapGestureRecognizer *singleClickTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeView)];
    singleClickTap.numberOfTapsRequired = 1;
    [self.closeButton setUserInteractionEnabled:YES];
    [self.closeButton addGestureRecognizer:singleClickTap];
    

}

-(void)closeView {
    SendGAEvent(@"user_action", @"photopon_camera", @"close_clicked");
    [self dismissViewControllerAnimated:TRUE completion:nil];
}


-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self selectWidth:1];

    if (!self.tooltip) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (!self.tooltip) {
                self.tooltip = [TooltipFactory showPersonalizeTooltipForView:self.view frame:[self.saveButton.superview convertRect:self.saveButton.frame toView:self.view]];
            }
        });
    }

}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
}



-(void)viewWillAppear:(BOOL)animated {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"PhotoponDrawScreen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    SendGAEvent(@"user_action", @"photopon_camera", @"opened");
    
}

#pragma mark - Friend picker delegate

-(void)didFinishSelecting:(NSArray *)friends {
    [self sendPhotopons:friends];
}

-(void)didCancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
