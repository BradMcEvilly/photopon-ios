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
#import "HeaderViewController.h"
#import "AlertBox.h"

@implementation MerchantInfoPage

-(void)showAlert: (NSString*)title : (NSString*) error {

    [AlertBox showAlertFor:self
                 withTitle:title
               withMessage:error
                leftButton:nil
               rightButton:@"OK"
                leftAction:nil
               rightAction:nil];
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
        [self showAlert:@"Error": @"Please enter valid business phone number"];
        return;
    }

    if (self.locationsPhoneNumber.text.length > 0 && ![self validatePhone:self.locationsPhoneNumber.text]) {
        [self showAlert:@"Error": @"Please enter valid location's phone number"];
        return;
    }
    
    PFObject *merchantRequest = [PFObject objectWithClassName:@"MerchantRequests"];
    merchantRequest[@"user"] = [PFUser currentUser];
    merchantRequest[@"businessName"] = self.infoBusinessName.text;
    merchantRequest[@"taxID"] = self.infoTaxID.text;
    merchantRequest[@"phoneNumber"] = self.infoBusinessPhone.text;

    // TODO check with Hayk about this
    merchantRequest[@"locationsPhoneNumber"] = self.infoBusinessPhone.text;

    [merchantRequest saveInBackground];
    SendGAEvent(@"user_action", @"merchant_info", @"request_sent");
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

    [HeaderViewController addBackHeaderToView:self withTitle:@"Merchant Info"];
}




-(void)viewWillAppear:(BOOL)animated {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"MerchantInfoScreen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    SendGAEvent(@"user_action", @"merchant_info", @"opened");
}



@end
