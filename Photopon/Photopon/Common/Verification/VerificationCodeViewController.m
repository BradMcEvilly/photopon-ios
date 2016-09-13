//
//  VerificationCodeViewController.m
//  Photopon
//
//  Created by Hayk Hayotsyan on 6/9/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import "VerificationCodeViewController.h"
#import "NumberVerificationViewController.h"
#import "IndicatorViewController.h"
#import "AlertBox.h"

@interface VerificationCodeViewController ()

@end

@implementation VerificationCodeViewController
{
    NumberVerificationViewController* parentCtrl;
}


- (void)viewDidLoad {
    [super viewDidLoad];


    
    [self.verifyButton addTarget:self action:@selector(doVerify) forControlEvents:UIControlEventTouchDown];
    [self.resendCodeBtn addTarget:self action:@selector(sendCodeAndAlert) forControlEvents:UIControlEventTouchDown];
    [self.cancelVerifyBtn addTarget:self action:@selector(verifyLater) forControlEvents:UIControlEventTouchDown];
}


-(void) verifyLater {
    [parentCtrl dismissViewControllerAnimated:YES completion:nil];
    
    SendGAEvent(@"user_action", @"number_verification", @"verify_later");
}



-(void) sendCodeAndAlert {
    
    [parentCtrl.phoneNumberCtrl sendCode];
    
    
    [AlertBox showAlertFor:self
                 withTitle:@"Verification"
               withMessage:@"New verification code was sent to your number"
                leftButton:nil
               rightButton:@"OK"
                leftAction:nil
               rightAction:nil];
    
    SendGAEvent(@"user_action", @"number_verification", @"resend_code_clicked");
    
}




-(void)setParent:(UIViewController*) viewCtrl {
    parentCtrl = (NumberVerificationViewController*)viewCtrl;
}



- (void) shakeVerification {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.duration = 0.6;
    animation.values = @[ @(-20), @(20), @(-20), @(20), @(-10), @(10), @(-5), @(5), @(0) ];
    [self.view.layer addAnimation:animation forKey:@"shake"];
}


-(void)doVerify {
    
    SendGAEvent(@"user_action", @"number_verification", @"verify_clicked");
    if (![[parentCtrl.sentCode stringValue] isEqualToString: self.verificationCode.text]) {
        [self shakeVerification];
        SendGAEvent(@"user_action", @"number_verification", @"wrong_code");
        return;
    }
    
    IndicatorViewController* ind = [IndicatorViewController showIndicator:parentCtrl withText:@"Verifying code..." timeout:60];
    
    PFQuery* query = [PFUser query];
    [query whereKey:@"phone" equalTo:NumbersFromFormattedPhone(parentCtrl.phoneNumberCtrl.phoneNumber.text)];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        [ind remove];
        
        if ([objects count] > 0) {
            
            [PFCloud callFunctionInBackground: @"getUserSessionToken" withParameters:@{
                @"phoneNumber": parentCtrl.phoneNumberCtrl.phoneNumber.text
            } block:^(id  _Nullable object, NSError * _Nullable error) {
                NSLog(@"%@", object);
                [PFUser becomeInBackground:object block:^(PFUser * _Nullable user, NSError * _Nullable error) {
                    [parentCtrl welcomeUser: user];
                }];

            }];
            
        } else {
            [parentCtrl newUserName];
        }
    }];
    
}




@end
