//
//  UITheme.h
//  Photopon
//
//  Created by Hayk Hayotsyan on 2/2/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UITheme : NSObject

+(UITheme*)themeWithHeaderColor: (UIColor*)headerColor headerTextColor:(UIColor*)headerTextColor;


@property UIColor* headerColor;
@property UIColor* headerTextColor;




+(UITheme*)whiteTheme;
+(UITheme*)greenTheme;
+(UITheme*)pinkTheme;
+(UITheme*)orangeTheme;
+(UITheme*)blackTheme;
+(UITheme*)blueTheme;
+(UITheme*)tealTheme;

+(UITheme*)redTheme;
+(UITheme*)yellowTheme;
@end


