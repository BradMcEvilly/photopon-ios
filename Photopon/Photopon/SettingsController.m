//
//  SettingsController.m
//  Photopon
//
//  Created by Hayk Hayotsyan on 27/8/15.
//  Copyright (c) 2015 Photopon. All rights reserved.
//

#import "SettingsController.h"
#import "Parse/Parse.h"

#import <ImageIO/CGImageProperties.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "DBAccess.h"
#import "HeaderViewController.h"
#import "AlertBox.h"
#import <MBProgressHUD/MBProgressHUD.h>

@implementation SettingsController


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:NULL];

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    SaveImage(@"profile.jpg", chosenImage, ^(PFFile *file, NSError *error) {
        PFUser* user = [PFUser currentUser];
        [user setValue:file forKey:@"image"];
        [user save];
        SendGAEvent(@"user_action", @"settings", @"profile_image_uploaded");
        
        
        [self.photoView sd_setImageWithURL:[NSURL URLWithString:file.url] placeholderImage:[UIImage imageNamed:@"profileplaceholder.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            self.photoView.layer.cornerRadius = 64;
            self.photoView.layer.masksToBounds = YES;
        }];
    });
}


-(void)changePhotoCallback {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:NULL];
}



-(void)requestMerchantCallback {
    
    UIViewController* merchantInfo = (UIViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"SBMerchantInfo"];
    
    [self presentViewController:merchantInfo animated:YES completion:nil];
    
}


- (UIViewController*) topMostController {
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}


-(void)changePhoneNumber {
    SendGAEvent(@"user_action", @"settings", @"change_number");
    UIViewController* mainCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"SBNumberVerification"];
    [[self topMostController] presentViewController:mainCtrl animated:true completion:nil];
    
}

-(void)removeNumber {
    SendGAEvent(@"user_action", @"settings", @"remove_number");
    
    PFUser *user = [PFUser currentUser];
    [user removeObjectForKey:@"phone"];
    
    
    self.phoneBox.hidden = YES;
    self.noPhoneBox.hidden = NO;
    
    
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        
        if (!error) {
            
            
            [AlertBox showAlertFor:self withTitle:@"Removed" withMessage:@"Your number has been successfully removed" leftButton:nil rightButton:@"OK" leftAction:nil rightAction:nil];
            
            self.phoneBox.hidden = YES;
            self.noPhoneBox.hidden = NO;

        }
    }];
}

-(void)viewDidLoad
{
    [super viewDidLoad];

    self.changeNumber.layer.cornerRadius = 8;
    self.changeNumber.layer.masksToBounds = YES;

    [self.changePhoto addTarget:self action:@selector(changePhotoCallback) forControlEvents:UIControlEventTouchDown];
    [self.requestMerchant addTarget:self action:@selector(requestMerchantCallback) forControlEvents:UIControlEventTouchDown];
    
    [self.changeNumber addTarget:self action:@selector(changePhoneNumber) forControlEvents:UIControlEventTouchDown];
    [self.addPhoneNumber addTarget:self action:@selector(changePhoneNumber) forControlEvents:UIControlEventTouchDown];

    
    [self.removeNumberBtn addTarget:self action:@selector(removeNumber) forControlEvents:UIControlEventTouchDown];
    
    
}




-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"SettingsScreen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    
    PFUser* user = [PFUser currentUser];
    PFFile* file = [user objectForKey:@"image"];
    
    if (file != nil) {
        [self.photoView sd_setImageWithURL:[NSURL URLWithString:file.url] placeholderImage:[UIImage imageNamed:@"profileplaceholder.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            self.photoView.layer.cornerRadius = 64;
            self.photoView.layer.masksToBounds = YES;
        }];
    }
    
    NSString* phoneNum = [user objectForKey:@"phone"];
    if (phoneNum) {
        self.phoneNumber.text = phoneNum;
        self.phoneBox.hidden = NO;
        self.noPhoneBox.hidden = YES;
    } else {
        self.phoneBox.hidden = YES;
        self.noPhoneBox.hidden = NO;
    }
    
    self.userName.text = [user username];
}


- (IBAction)closeButtonHandler:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end
