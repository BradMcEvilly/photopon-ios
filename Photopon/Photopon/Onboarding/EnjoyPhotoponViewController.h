//
//  EnjoyPhotoponViewController.h
//  Photopon
//
//  Created by Ante Karin on 11/09/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EnjoyPhotoponDelegate <NSObject>

- (void)userShouldRegister;

@end

@interface EnjoyPhotoponViewController : UIViewController

@property (nonatomic, weak) id<EnjoyPhotoponDelegate> delegate;

@end
