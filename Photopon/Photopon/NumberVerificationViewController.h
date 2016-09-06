//
//  NumberVerificationViewController.h
//  Photopon
//
//  Created by Hayk Hayotsyan on 19/12/15.
//  Copyright © 2015 Photopon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VerificationPhoneNumberViewController.h"
#import "VerificationCodeViewController.h"
#import "VerificationScreenNameViewController.h"
#import "VerificationWelcomeViewController.h"

@interface NumberVerificationViewController : UIViewController


@property (weak, nonatomic) VerificationPhoneNumberViewController* phoneNumberCtrl;
@property (weak, nonatomic) VerificationCodeViewController* codeCtrl;
@property (weak, nonatomic) VerificationScreenNameViewController* screenCtrl;
@property (weak, nonatomic) VerificationWelcomeViewController* welcomeCtrl;

@property (retain, nonatomic) NSNumber* sentCode;


-(void)sendingCode;
-(void)codeSent;
-(void)newUserName;
-(void)welcomeUser:(PFUser*)user;
@end
