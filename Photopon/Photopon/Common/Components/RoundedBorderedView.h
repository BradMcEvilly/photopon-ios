//
//  RoundedBorderedView.h
//  Photopon
//
//  Created by Ante Karin on 02/10/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RoundedBorderedView : UIView

@property (nonatomic, assign) UIRectCorner corners;
@property (nonatomic, strong) UIColor *borderColor;

@end
