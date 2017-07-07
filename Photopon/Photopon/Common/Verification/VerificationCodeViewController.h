//
//  VerificationCodeViewController.h
//  Photopon
//
//  Created by Hayk Hayotsyan on 6/9/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NumberVerificationDelegate;

@interface VerificationCodeViewController : UIViewController<UITextFieldDelegate>


@property (weak, nonatomic) IBOutlet UITextField *digit1;
@property (weak, nonatomic) IBOutlet UITextField *digit2;
@property (weak, nonatomic) IBOutlet UITextField *digit3;
@property (weak, nonatomic) IBOutlet UITextField *digit4;
@property (weak, nonatomic) IBOutlet UITextField *keySnatch;

@property (weak, nonatomic) IBOutlet UIButton *resendCodeBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelVerifyBtn;

-(void)setParent:(UIViewController*) viewCtrl;

@end
