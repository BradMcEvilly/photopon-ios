//
//  NumberVerificationViewController.m
//  Photopon
//
//  Created by Hayk Hayotsyan on 19/12/15.
//  Copyright © 2015 Photopon. All rights reserved.
//

#import "NumberVerificationViewController.h"
#import "PhoneNumberFormatter.h"
#import "HeaderViewController.h"
#import "IndicatorViewController.h"
#import "AlertBox.h"

@interface NumberVerificationViewController ()

@end




@implementation NumberVerificationViewController

{
    NSNumber* sentCode;
    NSDictionary* userInfo;
    id targetObject;
    SEL targetAction;
    PhoneNumberFormatter *myPhoneNumberFormatter;

}

-(void)setTarget:(id)object withAction:(SEL)action {
    targetObject = object;
    targetAction = action;
}




- (UIViewController*) topMostController {
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}

- (void)autoFormatTextField:(id)sender {
    
    self.phoneNumber.text = [myPhoneNumberFormatter format:self.phoneNumber.text withLocale:@"us"];
    
}



- (void) shakeVerification {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.duration = 0.6;
    animation.values = @[ @(-20), @(20), @(-20), @(20), @(-10), @(10), @(-5), @(5), @(0) ];
    [self.verifyView.layer addAnimation:animation forKey:@"shake"];
}


-(void)doVerify {
    
    SendGAEvent(@"user_action", @"number_verification", @"verify_clicked");
    if (![[sentCode stringValue] isEqualToString: self.verificationCode.text]) {
        self.wrongCode.text = @"Wrong verification code!";
        self.wrongCode.alpha = 1;
        [self shakeVerification];
        SendGAEvent(@"user_action", @"number_verification", @"wrong_code");
        return;
    }
    
    
    PFUser *user = [PFUser currentUser];
  
    user[@"phone"] = self.phoneNumber.text;
    
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        
        if (!error) {
            
            [self dismissViewControllerAnimated:YES completion:nil];
            
            
            UIViewController* mainCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"MainCtrl"];
            [[self topMostController] presentViewController:mainCtrl animated:true completion:nil];
        
            SendGAEvent(@"user_action", @"number_verification", @"number_verified");
        } else {
            self.wrongCode.text = @"Server error. Please try again.";
            self.wrongCode.alpha = 1;
            [self shakeVerification];
        }
    }];

}

-(void) sendCodeAndAlert {
    
    [self sendCode];
    
    
    [AlertBox showAlertFor:self
                 withTitle:@"Verification"
               withMessage:@"New verification code was sent to your number"
                leftButton:nil
               rightButton:@"OK"
                leftAction:nil
               rightAction:nil];
    
    SendGAEvent(@"user_action", @"number_verification", @"resend_code_clicked");
    
}



-(void) sendCode {
        
    PFObject *verification = [PFObject objectWithClassName:@"Verifications"];
    sentCode = [NSNumber numberWithInt:arc4random_uniform(900000) + 100000];
    
    verification[@"userName"] = [[PFUser currentUser] username];
    verification[@"code"] = [NSString stringWithFormat:@"%d", [sentCode intValue]];
    
    verification[@"phoneNumber"] = NumbersFromFormattedPhone(self.phoneNumber.text);
    verification[@"numTried"] = [NSNumber numberWithInt:0];
    
    IndicatorViewController* ind = [IndicatorViewController showIndicator:self withText:@"Sending verification code..." timeout:60];
    [self.phoneView setHidden:YES];

    [verification saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [ind remove];
        if (succeeded) {
            [self.verifyView setHidden:NO];
        } else {

        }
    }];
    
    SendGAEvent(@"user_action", @"number_verification", @"send_code_clicked");
    

}

-(void) verifyLater {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    SendGAEvent(@"user_action", @"number_verification", @"verify_later");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [HeaderViewController addBackHeaderToView:self withTitle:@"Verification"];

    
    
    [self.phoneView setHidden:NO];
    [self.verifyView setHidden:YES];
    
    myPhoneNumberFormatter = [[PhoneNumberFormatter alloc] init];
    
    [self.phoneNumber addTarget:self
                         action:@selector(autoFormatTextField:)
               forControlEvents:UIControlEventEditingChanged];
    
    
    
    [self.verifyButton addTarget:self action:@selector(doVerify) forControlEvents:UIControlEventTouchDown];

    [self.sendCodeBtn addTarget:self action:@selector(sendCode) forControlEvents:UIControlEventTouchDown];
    [self.resendCodeBtn addTarget:self action:@selector(sendCodeAndAlert) forControlEvents:UIControlEventTouchDown];
    
    [self.verifyLaterBtn addTarget:self action:@selector(verifyLater) forControlEvents:UIControlEventTouchDown];
    [self.cancelVerifyBtn addTarget:self action:@selector(verifyLater) forControlEvents:UIControlEventTouchDown];

}

#pragma mark - Check user number

- (BOOL)checkIfUserNumberAlreadyUsed {
    return NO;
}

- (BOOL)checkIfPhoneInMerchantList {
    return NO;
}

- (BOOL)checkIfNumberWasInvited {
    return NO;
}

@end
