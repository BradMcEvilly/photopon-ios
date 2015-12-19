//
//  NumberVerificationViewController.m
//  Photopon
//
//  Created by Hayk Hayotsyan on 19/12/15.
//  Copyright © 2015 Photopon. All rights reserved.
//

#import "NumberVerificationViewController.h"

@interface NumberVerificationViewController ()

@end


@implementation NumberVerificationViewController

{
    NSNumber* sentCode;
    NSDictionary* userInfo;
    id targetObject;
    SEL targetAction;
}

-(void)setTarget:(id)object withAction:(SEL)action {
    targetObject = object;
    targetAction = action;
}

-(void)doVerify {
    if (![[sentCode stringValue] isEqualToString: self.verificationCode.text]) {
        self.wrongCode.alpha = 1;
        return;
    }
    
    
    PFUser *user = [PFUser user];
    user.username = userInfo[@"username"];
    user.password = userInfo[@"password"];
    user.email = userInfo[@"email"];
    
    // other fields can be set just like with PFObject
    user[@"phone"] = userInfo[@"additional"];
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            [targetObject performSelector:targetAction];

        } else {
            NSString *errorString = [error userInfo][@"error"];
        }
    }];

}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.verifyButton addTarget:self action:@selector(doVerify) forControlEvents:UIControlEventTouchDown];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)initWithCode:(NSNumber*)code userInfo:(NSDictionary*)info {
    sentCode = code;
    userInfo = info;
    
    
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
