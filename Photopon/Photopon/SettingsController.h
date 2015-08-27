//
//  SettingsController.h
//  Photopon
//
//  Created by Hayk Hayotsyan on 27/8/15.
//  Copyright (c) 2015 Photopon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsController : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@property (weak, nonatomic) IBOutlet UIButton *changePhoto;
@property (weak, nonatomic) IBOutlet UIButton *requestMerchant;

@end
