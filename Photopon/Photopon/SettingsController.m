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

@implementation SettingsController


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:NULL];

    SaveImage(@"profile.jpg", chosenImage, ^(PFFile *file, NSError *error) {
        PFUser* user = [PFUser currentUser];
        [user setValue:file forKey:@"image"];
        [user save];
        
        
        [self.photoView sd_setImageWithURL:[NSURL URLWithString:file.url] placeholderImage:[UIImage imageNamed:@"profileplaceholder.png"]];
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
    
    [self.navigationController pushViewController:merchantInfo animated:true];
    
}


- (UIViewController*) topMostController {
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}


-(void)changePhoneNumber {
    UIViewController* mainCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"SBNumberVerification"];
    [[self topMostController] presentViewController:mainCtrl animated:true completion:nil];
    
}

-(void)removeNumber {
    PFUser *user = [PFUser currentUser];
    [user removeObjectForKey:@"phone"];
    
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        
        if (!error) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Removed"
                                                            message:@"Your number has been successfully removed"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            
            self.phoneBox.hidden = YES;
            self.noPhoneBox.hidden = NO;

        }
    }];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
   
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
        [self.photoView sd_setImageWithURL:[NSURL URLWithString:file.url] placeholderImage:[UIImage imageNamed:@"profileplaceholder.png"]];
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





@end
