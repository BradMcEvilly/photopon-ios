//
//  NumberVerificationViewController.m
//  Photopon
//
//  Created by Hayk Hayotsyan on 19/12/15.
//  Copyright © 2015 Photopon. All rights reserved.
//

#import "NumberVerificationViewController.h"
#import "HeaderViewController.h"
#import "IndicatorViewController.h"
#import "AlertBox.h"
#import "VerificationPhoneNumberViewController.h"
#import "VerificationCodeViewController.h"
#import "VerificationWelcomeViewController.h"

@interface NumberVerificationViewController ()

@end

@implementation NumberVerificationViewController
{
    NSDictionary* userInfo;
    id targetObject;
    SEL targetAction;

}
@synthesize sentCode;


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


-(UIViewController*)createSubView:(NSString*)storyBoardName {
    UIViewController* ctrl = [self.storyboard instantiateViewControllerWithIdentifier:storyBoardName];
    ctrl.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 60, [UIScreen mainScreen].bounds.size.height - 100);
    
    CGPoint ct = self.view.center;
    ct.y = ct.y + 100;
    ctrl.view.center = ct;
    
    
    [self.view addSubview:ctrl.view];
    [self addChildViewController:ctrl];
    [ctrl didMoveToParentViewController:self];
    return ctrl;
}


-(void)sendingCode {
    [_phoneNumberCtrl.view setHidden: YES];
}

-(void)codeSent {
    [_codeCtrl.view setHidden: NO];
}


-(void)newUserName {
    [_codeCtrl.view setHidden: YES];
    [_screenCtrl.view setHidden:NO];    
}

-(void)welcomeUser:(PFUser*)user {
    [_codeCtrl.view setHidden:YES];
    [_welcomeCtrl.view setHidden:NO];
    [_welcomeCtrl setUserName:[user username]];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    _phoneNumberCtrl = (VerificationPhoneNumberViewController*)[self createSubView:@"SBVerificationPhoneNumber"];
    
    _codeCtrl = (VerificationCodeViewController*)[self createSubView:@"SBVerificationCode"];
    _screenCtrl = (VerificationScreenNameViewController*)[self createSubView:@"SBVerificationName"];
    _screenCtrl.delegate = self.delegate;
    _welcomeCtrl = (VerificationWelcomeViewController*)[self createSubView:@"SBVerificationWelcome"];
    
    [_phoneNumberCtrl setParent:self];
    [_codeCtrl setParent:self];
    [_screenCtrl setParent: self];
    [_welcomeCtrl setParent: self];
    
    [_codeCtrl.view setHidden: YES];
    [_screenCtrl.view setHidden:YES];
    [_welcomeCtrl.view setHidden:YES];

#ifdef DEBUG
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.delegate userVerifiedPhoneNumber];
    });
#endif

}

-(void)setDelegate:(id<NumberVerificationDelegate>)delegate {
    _delegate = delegate;
    self.screenCtrl.delegate = delegate;
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
