//
//  PhotoponViewController.m
//  Photopon
//
//  Created by Hayk Hayotsyan on 31/8/15.
//  Copyright (c) 2015 Photopon. All rights reserved.
//

#import "PhotoponViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Helper.h"

@implementation PhotoponViewController
{
    PFObject* photopon;
}

-(void)setPhotopon:(PFObject*)obj {
    photopon = obj;
}

-(void)savePhotopon {
    PFObject* newWalletObject = [PFObject objectWithClassName:@"Wallet"];
    [newWalletObject setObject:[PFUser currentUser] forKey:@"user"];
    [newWalletObject setObject:photopon forKey:@"photopon"];
    [newWalletObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *PF_NULLABLE_S error) {
        [self dismissViewControllerAnimated:true completion:^{
            
        }];
    }];
}

-(void)viewDidLoad {
    
    PFFile* drawingFile = [photopon objectForKey:@"drawing"];
    PFFile* photoFile = [photopon objectForKey:@"photo"];
    
    PFObject* coupon = [photopon objectForKey:@"coupon"];
    PFFile* companyLogoFile = [[coupon objectForKey:@"company"] objectForKey:@"image"];
    
    [self.photoImage sd_setImageWithURL:[NSURL URLWithString:photoFile.url]];
    [self.drawingImage sd_setImageWithURL:[NSURL URLWithString:drawingFile.url]];
    
    [self.companyLogo sd_setImageWithURL:[NSURL URLWithString:companyLogoFile.url]];
    
    [self.couponTitle setText:[coupon objectForKey:@"title"]];
    [self.couponDescription setText:[coupon objectForKey:@"description"]];
    
    UIImageView* icon = CreateFAImage(@"fa-suitcase", 34);
    [self.saveButtonIcon addSubview:icon];

    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(savePhotopon)];
    [self.view addGestureRecognizer:singleFingerTap];
  
}




-(void)viewWillAppear:(BOOL)animated {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"PhotoponViewScreen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}



@end
