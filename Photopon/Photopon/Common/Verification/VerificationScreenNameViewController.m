//
//  VerificationScreenNameViewController.m
//  Photopon
//
//  Created by Hayk Hayotsyan on 6/9/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import "VerificationScreenNameViewController.h"
#import "NumberVerificationViewController.h"
#import "IndicatorViewController.h"
#import "AlertBox.h"

@interface VerificationScreenNameViewController ()

@end

@implementation VerificationScreenNameViewController
{
    NumberVerificationViewController* parentCtrl;
}


-(void) cancelCallback {
    [parentCtrl dismissViewControllerAnimated:YES completion:nil];
}



-(NSString*)generateRandomPassword {
    return [[NSProcessInfo processInfo] globallyUniqueString];
}



-(void) doRegister {
    
    if ([_screenName.text isEqualToString:@""]) {
        
        [AlertBox showAlertFor:self
                     withTitle:@"Screen name"
                   withMessage:@"Please enter screen name"
                    leftButton:nil
                   rightButton:@"OK"
                    leftAction:nil
                   rightAction:nil];
        return;
    }
    
    
    IndicatorViewController* ind = [IndicatorViewController showIndicator:parentCtrl withText:@"Registering user..." timeout:60];

    
    PFQuery* query = [PFUser query];
    [query whereKey:@"username" equalTo: _screenName.text];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if ([objects count] > 0) {
            [ind remove];
     
            [AlertBox showAlertFor:self
                         withTitle:@"Screen name"
                       withMessage:@"Screen name is alreay used. Please pick another screen name."
                        leftButton:nil
                       rightButton:@"OK"
                        leftAction:nil
                       rightAction:nil];
        } else {
            
            PFUser *user = [PFUser new];
            [user setObject:[self generateRandomPassword] forKey:@"password"];
            [user setObject:NumbersFromFormattedPhone(parentCtrl.phoneNumberCtrl.phoneNumber.text) forKey:@"phone"];
            [user setObject:_screenName.text forKey:@"username"];
            
            [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if (!error) {
                    [self dismissViewControllerAnimated:YES completion:^{
                        [self.delegate userVerifiedPhoneNumber];
                    }];
                } else {
                    [AlertBox showAlertFor:self
                                 withTitle:@"Registration Error"
                               withMessage:@"There was an error registering your account. Please try again."
                                leftButton:nil
                               rightButton:@"OK"
                                leftAction:nil
                               rightAction:nil];
                }
                
                [ind remove];
            }];
            
        }
    }];

}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.getStarted.layer.cornerRadius = 8;
    self.getStarted.layer.masksToBounds = YES;

    [self.getStarted addTarget:self action:@selector(doRegister) forControlEvents:UIControlEventTouchDown];
    [self.cancelButton addTarget:self action:@selector(cancelCallback) forControlEvents:UIControlEventTouchDown];
}



-(void)setParent:(UIViewController*) viewCtrl {
    parentCtrl = (NumberVerificationViewController*)viewCtrl;
}



@end
