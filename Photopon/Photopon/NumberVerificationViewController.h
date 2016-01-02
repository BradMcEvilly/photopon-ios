//
//  NumberVerificationViewController.h
//  Photopon
//
//  Created by Hayk Hayotsyan on 19/12/15.
//  Copyright © 2015 Photopon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NumberVerificationViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *verifyButton;
@property (weak, nonatomic) IBOutlet UITextField *verificationCode;
@property (weak, nonatomic) IBOutlet UILabel *wrongCode;


@property (weak, nonatomic) IBOutlet UIButton *sendCodeBtn;
@property (weak, nonatomic) IBOutlet UIButton *verifyLaterBtn;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumber;



@property (weak, nonatomic) IBOutlet UIView *phoneView;
@property (weak, nonatomic) IBOutlet UIView *verifyView;

@property (weak, nonatomic) IBOutlet UIButton *cancelVerifyBtn;
@property (weak, nonatomic) IBOutlet UIButton *resendCodeBtn;

@end
