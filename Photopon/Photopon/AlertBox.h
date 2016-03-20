//
//  AlertBox.h
//  Photopon
//
//  Created by Hayk Hayotsyan on 17/3/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlertBox : UIViewController

@property (weak, nonatomic) id parentObject;
@property (weak, nonatomic) UIViewController* topController;

@property SEL rightAction;
@property SEL leftAction;


@property (weak, nonatomic) IBOutlet UILabel *alertTitle;
@property (weak, nonatomic) IBOutlet UILabel *alertMessage;

@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;

+(AlertBox*)showAlertFor:(id)parent
               withTitle:(NSString*)title
             withMessage:(NSString*)message
              leftButton:(NSString*)leftButton
             rightButton:(NSString*)rightButton
              leftAction:(SEL)leftAction
             rightAction:(SEL)rightAction;


+(AlertBox*)showMessageFor:(id)parent
               withTitle:(NSString*)title
             withMessage:(NSString*)message
              leftButton:(NSString*)leftButton
             rightButton:(NSString*)rightButton
              leftAction:(SEL)leftAction
             rightAction:(SEL)rightAction;


-(void)closeBox;

@end
