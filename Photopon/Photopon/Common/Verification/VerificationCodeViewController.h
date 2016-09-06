//
//  VerificationCodeViewController.h
//  Photopon
//
//  Created by Hayk Hayotsyan on 6/9/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VerificationCodeViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *verificationCode;

@property (weak, nonatomic) IBOutlet UIButton *verifyButton;
@property (weak, nonatomic) IBOutlet UIButton *resendCodeBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelVerifyBtn;


-(void)setParent:(UIViewController*) viewCtrl;

@end
