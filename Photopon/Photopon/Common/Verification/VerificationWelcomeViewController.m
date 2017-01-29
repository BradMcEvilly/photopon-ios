//
//  VerificationWelcomeViewController.m
//  Photopon
//
//  Created by Hayk Hayotsyan on 6/9/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import "VerificationWelcomeViewController.h"
#import "NumberVerificationViewController.h"


@interface VerificationWelcomeViewController ()

@end

@implementation VerificationWelcomeViewController
{
    NumberVerificationViewController* parentCtrl;
}


-(void) cancelCallback {
    [parentCtrl dismissViewControllerAnimated:YES completion:nil];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.getStarted addTarget:self action:@selector(cancelCallback) forControlEvents:UIControlEventTouchDown];

    self.getStarted.layer.cornerRadius = 8;
    self.getStarted.layer.masksToBounds = YES;
}


-(void)setParent:(UIViewController*) viewCtrl {
    parentCtrl = (NumberVerificationViewController*)viewCtrl;
}

-(void)setUserName:(NSString*)userName {
    _usernameField.text = userName;
}

@end
