//
//  VerificationPhoneNumberViewController.m
//  Photopon
//
//  Created by Hayk Hayotsyan on 6/9/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import "VerificationPhoneNumberViewController.h"
#import "IndicatorViewController.h"
#import "PhoneNumberFormatter.h"
#import "NumberVerificationViewController.h"
#import "AlertBox.h"

@interface VerificationPhoneNumberViewController ()

@end

@implementation VerificationPhoneNumberViewController
{
    NumberVerificationViewController* parentCtrl;
    PhoneNumberFormatter *myPhoneNumberFormatter;

}


- (void)autoFormatTextField:(id)sender {
    self.phoneNumber.text = [myPhoneNumberFormatter format:self.phoneNumber.text withLocale:@"us"];
}


- (void)viewDidLoad {
    [super viewDidLoad];

    self.sendCodeBtn.layer.cornerRadius = 8;
    self.sendCodeBtn.layer.masksToBounds = YES;

    myPhoneNumberFormatter = [[PhoneNumberFormatter alloc] init];
    
    [self.phoneNumber addTarget:self
                         action:@selector(autoFormatTextField:)
               forControlEvents:UIControlEventEditingChanged];
    

    [self.sendCodeBtn addTarget:self action:@selector(sendCode) forControlEvents:UIControlEventTouchDown];
    [self.verifyLaterBtn addTarget:self action:@selector(verifyLater) forControlEvents:UIControlEventTouchDown];

}


-(void)setParent:(UIViewController*) viewCtrl {
    parentCtrl = (NumberVerificationViewController*)viewCtrl;
}

-(void) sendCode {
    
    
    if ([_phoneNumber.text isEqualToString:@""]) {
        
        [AlertBox showAlertFor:self
                     withTitle:@"Phone number"
                   withMessage:@"Please enter a phone number"
                    leftButton:nil
                   rightButton:@"OK"
                    leftAction:nil
                   rightAction:nil];
        return;
    }

    
    IndicatorViewController* ind = [IndicatorViewController showIndicator:parentCtrl withText:@"Sending verification code..." timeout:60];
    
    
    PFObject *verification = [PFObject objectWithClassName:@"Verifications"];
    NSNumber* newCode = [NSNumber numberWithInt:arc4random_uniform(900000) + 100000];
    parentCtrl.sentCode = newCode;
    
    verification[@"code"] = [NSString stringWithFormat:@"%d", [parentCtrl.sentCode intValue]];
    verification[@"phoneNumber"] = NumbersFromFormattedPhone(self.phoneNumber.text);
    verification[@"numTried"] = [NSNumber numberWithInt:0];
    
    [parentCtrl sendingCode];
    
    [verification saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [ind remove];
        if (succeeded) {
            [parentCtrl codeSent];
        } else {
            [self dismissViewControllerAnimated:YES completion:nil];
            [ind remove];
        }
    }];
    
    SendGAEvent(@"user_action", @"number_verification", @"send_code_clicked");
    
}

-(void) verifyLater {
    [parentCtrl dismissViewControllerAnimated:YES completion:nil];
    [self.delegate userSkippedVerification];
    SendGAEvent(@"user_action", @"number_verification", @"verify_later");
}


@end
