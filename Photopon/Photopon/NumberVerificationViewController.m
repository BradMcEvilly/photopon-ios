//
//  NumberVerificationViewController.m
//  Photopon
//
//  Created by Hayk Hayotsyan on 19/12/15.
//  Copyright © 2015 Photopon. All rights reserved.
//

#import "NumberVerificationViewController.h"
#import "PhoneNumberFormatter.h"


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
    if (![[sentCode stringValue] isEqualToString: self.verificationCode.text]) {
        self.wrongCode.text = @"Wrong verification code!";
        self.wrongCode.alpha = 1;
        [self shakeVerification];
        return;
    }
    
    
    PFUser *user = [PFUser currentUser];
  
    user[@"phone"] = self.phoneNumber.text;
    
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        
        if (!error) {
            
            [self dismissViewControllerAnimated:YES completion:nil];
            
            
            UIViewController* mainCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"MainCtrl"];
            [[self topMostController] presentViewController:mainCtrl animated:true completion:nil];
        
            
        } else {
            self.wrongCode.text = @"Server error. Please try again.";
            self.wrongCode.alpha = 1;
            [self shakeVerification];
        }
    }];

}

-(void) sendCodeAndAlert {
    
    [self sendCode];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Verification"
                                                    message:@"New verification code was sent to your number"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK!"
                                          otherButtonTitles:nil];
    [alert show];
}



-(void) sendCode {
        
    PFObject *verification = [PFObject objectWithClassName:@"Verifications"];
    sentCode = [NSNumber numberWithInt:arc4random_uniform(900000) + 100000];
    
    verification[@"userName"] = [[PFUser currentUser] username];
    verification[@"code"] = [NSString stringWithFormat:@"%d", [sentCode intValue]];
    
    verification[@"phoneNumber"] = NumbersFromFormattedPhone(self.phoneNumber.text);
    verification[@"numTried"] = [NSNumber numberWithInt:0];
    
    self.phoneNumber.enabled = NO;
    [verification saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        self.phoneNumber.enabled = YES;
        
        if (succeeded) {
            [self.phoneView setHidden:YES];
            [self.verifyView setHidden:NO];
        } else {

        }
    }];
    

}

-(void) verifyLater {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
