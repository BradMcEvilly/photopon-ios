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


-(void)initWithCode:(NSNumber*)code userInfo:(NSDictionary*)info;
-(void)setTarget:(id)object withAction:(SEL)action;

@end
