//
//  MerchantInfoPage.m
//  Photopon
//
//  Created by Hayk Hayotsyan on 18/11/15.
//  Copyright © 2015 Photopon. All rights reserved.
//

#import "MerchantInfoPage.h"
#import <Parse/Parse.h>
#import <IQKeyboardManager/IQKeyboardManager.h>

@implementation MerchantInfoPage

-(void)showAlert: (NSString*)title : (NSString*) error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:error
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (BOOL)validatePhone:(NSString *)phoneNumber
{
    NSString *phoneRegex = @"^[1-9][0-9]{6,14}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    
    return [phoneTest evaluateWithObject:phoneNumber];
}


-(void)requestMerchantCallback {
    
    if ([self.infoBusinessName.text length] == 0) {
        [self showAlert:@"Error": @"Business Name can not be empty"];
        return;
    }
    
    
    if ([self.infoTaxID.text length] == 0) {
        [self showAlert:@"Error": @"Tax ID can not be empty"];
        return;
    }
    
    
    if ([self.infoBusinessPhone.text length] == 0) {
        [self showAlert:@"Error": @"Business Phone can not be empty"];
        return;
    }
    
    if (![self validatePhone:self.infoBusinessPhone.text]) {
        [self showAlert:@"Error": @"Please enter valid phone number"];
        return;
    }
    
    PFObject *merchantRequest = [PFObject objectWithClassName:@"MerchantRequests"];
    merchantRequest[@"user"] = [PFUser currentUser];
    merchantRequest[@"businessName"] = self.infoBusinessName.text;
    merchantRequest[@"taxID"] = self.infoTaxID.text;
    merchantRequest[@"phoneNumber"] = self.infoBusinessPhone.text;
    
    [merchantRequest saveInBackground];
    
    [self showAlert: @"Congratulations": @"Merchant request have been sent"];
    [self dismissViewControllerAnimated:YES completion:NULL];
   
}

-(void)viewDidLoad {
    
    [super viewDidLoad];
    
    [[IQKeyboardManager sharedManager] setEnable:YES];
    // optional
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:YES];
    [[IQKeyboardManager sharedManager] setShouldShowTextFieldPlaceholder:NO];
    [[IQKeyboardManager sharedManager] setShouldToolbarUsesTextFieldTintColor:NO];
    [[IQKeyboardManager sharedManager] setToolbarManageBehaviour:IQAutoToolbarByPosition];


    [self.requestMerchant addTarget:self action:@selector(requestMerchantCallback) forControlEvents:UIControlEventTouchDown];

}




-(void)viewWillAppear:(BOOL)animated {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"MerchantInfoScreen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}



@end
