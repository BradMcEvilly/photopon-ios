//
//  PhotoponViewController.m
//  Photopon
//
//  Created by Hayk Hayotsyan on 31/8/15.
//  Copyright (c) 2015 Photopon. All rights reserved.
//

#import "PhotoponViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>


@implementation PhotoponViewController
{
    PFObject* photopon;
}

-(void)setPhotopon:(PFObject*)obj {
    photopon = obj;
}


-(void)viewDidLoad {
    
    PFFile* drawingFile = [photopon objectForKey:@"drawing"];
    PFFile* photoFile = [photopon objectForKey:@"photo"];
    
    PFObject* coupon = [photopon objectForKey:@"coupon"];
    PFFile* companyLogoFile = [[coupon objectForKey:@"company"] objectForKey:@"image"];
    
    [self.photoImage sd_setImageWithURL:[NSURL URLWithString:photoFile.url] placeholderImage:[UIImage imageNamed:@"couponplaceholder.png"]];
    [self.drawingImage sd_setImageWithURL:[NSURL URLWithString:drawingFile.url] placeholderImage:[UIImage imageNamed:@"couponplaceholder.png"]];
    
    [self.companyLogo sd_setImageWithURL:[NSURL URLWithString:companyLogoFile.url] placeholderImage:[UIImage imageNamed:@"couponplaceholder.png"]];
    
    [self.couponTitle setText:[coupon objectForKey:@"title"]];
    [self.couponDescription setText:[coupon objectForKey:@"description"]];
    
    
}


@end
