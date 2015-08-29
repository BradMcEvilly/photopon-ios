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
    PFObject *merchantRequest = [PFObject objectWithClassName:@"MerchantRequests"];
    merchantRequest[@"user"] = [PFUser currentUser];
    [merchantRequest saveInBackground];
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Merchant Request"
                                                    message:@"Your request has been sent."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];

}




-(void)viewDidLoad
{
    [super viewDidLoad];
    
    PFUser* user = [PFUser currentUser];
    PFFile* file = [user objectForKey:@"image"];
    
    if (file != nil) {
        [self.photoView sd_setImageWithURL:[NSURL URLWithString:file.url] placeholderImage:[UIImage imageNamed:@"profileplaceholder.png"]];
    }
    
    [self.changePhoto addTarget:self action:@selector(changePhotoCallback) forControlEvents:UIControlEventTouchDown];
    [self.requestMerchant addTarget:self action:@selector(requestMerchantCallback) forControlEvents:UIControlEventTouchDown];

    
    
}




@end
