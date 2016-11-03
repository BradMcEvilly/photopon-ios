//
//  KeyboardAvoidanceManager.m
//  Photopon
//
//  Created by Ante Karin on 03/11/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import "KeyboardAvoidanceManager.h"

@interface KeyboardAvoidanceManager()

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) UIView *view;

@end

@implementation KeyboardAvoidanceManager

-(instancetype)initWithScrollView:(UIScrollView *)scrollView view:(UIView *)view {
    self = [super init];
    self.view = view;
    self.scrollView = scrollView;

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [view addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapDetected)]];

    return self;
}


-(void)keyboardWillHide:(NSNotification*)notification {
    self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
}

-(void)keyboardWillShow:(NSNotification*)notification {
    CGRect frame = [[[notification userInfo] valueForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue];
    self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, frame.size.height, 0);
}

-(void)tapDetected {
    [self.view endEditing:YES];
}

@end
