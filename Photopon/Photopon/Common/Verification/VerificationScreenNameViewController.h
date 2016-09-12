//
//  VerificationScreenNameViewController.h
//  Photopon
//
//  Created by Hayk Hayotsyan on 6/9/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VerificationScreenNameViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *screenName;
@property (weak, nonatomic) IBOutlet UIButton *getStarted;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;


-(void)setParent:(UIViewController*) viewCtrl;



@end
