//
//  PhotoponViewController.h
//  Photopon
//
//  Created by Hayk Hayotsyan on 31/8/15.
//  Copyright (c) 2015 Photopon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"

@interface PhotoponViewController : UIViewController

-(void)setPhotopon:(PFObject*)obj;
@property (weak, nonatomic) IBOutlet UIImageView *photoImage;
@property (weak, nonatomic) IBOutlet UIImageView *drawingImage;
@property (weak, nonatomic) IBOutlet UIImageView *companyLogo;

@property (weak, nonatomic) IBOutlet UILabel *couponTitle;
@property (weak, nonatomic) IBOutlet UILabel *couponDescription;

@end
