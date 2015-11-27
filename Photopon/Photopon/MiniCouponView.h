//
//  MiniCouponView.h
//  Photopon
//
//  Created by Hayk Hayotsyan on 25/10/15.
//  Copyright © 2015 Photopon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MiniCouponView : UIView<UIGestureRecognizerDelegate>

-(void)initView: (NSInteger)couponIndex;

-( UIGestureRecognizer* _Nonnull )getRightSwipe;
-( UIGestureRecognizer* _Nonnull )getLeftSwipe;

@end
