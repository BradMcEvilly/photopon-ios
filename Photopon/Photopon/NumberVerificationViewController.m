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
#import "KeyboardAvoidanceManager.h"
#import "UIView+CommonLayout.h"
@interface NumberVerificationViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (nonatomic, strong) KeyboardAvoidanceManager *keyboardManager;
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
    [self.containerView addSubviewAndFill:ctrl.view];
    [self addChildViewController:ctrl];
    [ctrl didMoveToParentViewController:self];
    return ctrl;
}


-(void)sendingCode {
    [_phoneNumberCtrl.view setHidden: YES];
}

-(void)codeSent {
    [_codeCtrl.view setHidden: NO];
    [_codeCtrl.verificationCode becomeFirstResponder];
}


-(void)newUserName {
    [_codeCtrl.view setHidden: YES];
    [_screenCtrl.screenName becomeFirstResponder];
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

    self.keyboardManager = [[KeyboardAvoidanceManager alloc]initWithScrollView:self.scrollView view:self.view];

    [_phoneNumberCtrl setParent:self];
    [_codeCtrl setParent:self];
    [_screenCtrl setParent: self];
    [_welcomeCtrl setParent: self];
    
    [_codeCtrl.view setHidden: YES];
    [_screenCtrl.view setHidden:YES];
    [_welcomeCtrl.view setHidden:YES];
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
