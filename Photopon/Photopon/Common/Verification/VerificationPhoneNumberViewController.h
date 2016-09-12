//
//  VerificationPhoneNumberViewController.h
//  Photopon
//
//  Created by Hayk Hayotsyan on 6/9/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VerificationPhoneNumberViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *sendCodeBtn;
@property (weak, nonatomic) IBOutlet UIButton *verifyLaterBtn;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumber;

-(void) sendCode;
-(void) setParent: (UIViewController*)viewCtrl;

@end
