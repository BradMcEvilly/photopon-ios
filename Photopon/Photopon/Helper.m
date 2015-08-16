//
//  Helper.m
//  Photopon
//
//  Created by Hayk Hayotsyan on 16/8/15.
//  Copyright (c) 2015 Photopon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Helper.h"
#import "FontAwesome/FAImageView.h"

UIImageView* CreateFAImage(NSString* type, CGFloat size) {
    FAImageView *imageView = [[FAImageView alloc] initWithFrame:CGRectMake(0.f, 0.f, size, size)];
    imageView.image = nil;

    imageView.defaultView.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    imageView.defaultView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];

    [imageView setDefaultIconIdentifier:type];
    return imageView;
}