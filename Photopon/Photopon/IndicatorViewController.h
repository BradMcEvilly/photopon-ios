//
//  IndicatorViewController.h
//  Photopon
//
//  Created by Hayk Hayotsyan on 20/1/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IndicatorViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *activityDescription;
@property (weak, nonatomic) IBOutlet UILabel *doneIndicator;

@property (weak, nonatomic) NSTimer* timoutTimer;
@property (weak, nonatomic) UIViewController* parentController;

+(IndicatorViewController*)showIndicator:(UIViewController*)parent withText:(NSString*)text timeout:(NSInteger)timeout;
+(IndicatorViewController*)showIndicator:(UIViewController*)parent withText:(NSString*)text timeout:(NSInteger)timeout withDelay:(float)delay;

-(void)hide;
-(void)remove;

@end
