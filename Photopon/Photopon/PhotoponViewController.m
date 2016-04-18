//
//  PhotoponViewController.m
//  Photopon
//
//  Created by Hayk Hayotsyan on 31/8/15.
//  Copyright (c) 2015 Photopon. All rights reserved.
//

#import "PhotoponViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "DBAccess.h"
#import "HeaderViewController.h"

@implementation PhotoponViewController
{
    PFObject* photopon;
}

-(void)setPhotopon:(PFObject*)obj {
    photopon = obj;
}

-(void)savePhotopon {
    SendGAEvent(@"user_action", @"photopon_view", @"save_clicked");
    
    if (HasPhoneNumber(@"You need to add phone number to be able to save Photopons.")) {
        PFObject* newWalletObject = [PFObject objectWithClassName:@"Wallet"];
        [newWalletObject setObject:[PFUser currentUser] forKey:@"user"];
        [newWalletObject setObject:photopon forKey:@"photopon"];
        [newWalletObject setObject:[NSNumber numberWithBool:NO] forKey:@"isUsed"];
        
        [newWalletObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
            
            CreateAddWalletNotification([photopon valueForKey:@"creator"], photopon);
            [self dismissViewControllerAnimated:true completion:^{
                
            }];
        }];
    } else {
        SendGAEvent(@"user_action", @"photopon_view", @"no_phone_number_to_save");
        
    }
}

-(void)viewDidLoad {
    
    [HeaderViewController addBackHeaderToView:self withTitle:@"Photopon"];

    
    PFFile* drawingFile = [photopon objectForKey:@"drawing"];
    PFFile* photoFile = [photopon objectForKey:@"photo"];
    
    PFObject* coupon = [photopon objectForKey:@"coupon"];
    PFFile* companyLogoFile = [[coupon objectForKey:@"company"] objectForKey:@"image"];
    
    if (![photoFile isKindOfClass:[NSNull class]])
        [self.photoImage sd_setImageWithURL:[NSURL URLWithString:photoFile.url]];
    
    if (![drawingFile isKindOfClass:[NSNull class]])
        [self.drawingImage sd_setImageWithURL:[NSURL URLWithString:drawingFile.url]];
    
    if (![companyLogoFile isKindOfClass:[NSNull class]])
        [self.companyLogo sd_setImageWithURL:[NSURL URLWithString:companyLogoFile.url]];
    
    [self.couponTitle setText:[coupon objectForKey:@"title"]];
    [self.couponDescription setText:[coupon objectForKey:@"description"]];
    

    [self.saveButton addTarget:self action:@selector(savePhotopon) forControlEvents:UIControlEventTouchDown];
  
}





-(void)viewWillAppear:(BOOL)animated {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"PhotoponViewScreen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}



@end
