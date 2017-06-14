//
//  VerificationWelcomeViewController.h
//  Photopon
//
//  Created by Hayk Hayotsyan on 6/9/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NumberVerificationDelegate;


@interface VerificationWelcomeViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *usernameField;
@property (weak, nonatomic) IBOutlet UIButton *getStarted;

@property (nonatomic, weak) id<NumberVerificationDelegate> delegate;


-(void)setParent:(UIViewController*) viewCtrl;
-(void)setUserName:(NSString*)userName;

@end
