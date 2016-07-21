//
//  AlertBox.m
//  Photopon
//
//  Created by Hayk Hayotsyan on 17/3/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import "AlertBox.h"

@interface AlertBox ()

@end

@implementation AlertBox

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)closeBox {
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

-(void)leftButtonPlaceholder {
    if (self.leftAction != nil) {
        [self.parentObject performSelector:self.leftAction];
    }
    [self closeBox];
}


-(void)rightButtonPlaceholder {
    if (self.rightAction != nil) {
        [self.parentObject performSelector:self.rightAction];
    }
    [self closeBox];

    
}



+(AlertBox*)showMessageFor:(id)parent
               withTitle:(NSString*)title
             withMessage:(NSString*)message
              leftButton:(NSString*)leftButton
             rightButton:(NSString*)rightButton
              leftAction:(SEL)leftAction
             rightAction:(SEL)rightAction {
    
    
    AlertBox* box = [AlertBox showAlertFor:parent withTitle:title withMessage:message leftButton:leftButton rightButton:rightButton leftAction:leftAction rightAction:rightAction];
    
    
    box.alertTitle.textColor = [UIColor colorWithRed:72.0/255 green:130.0/255 blue:20.0/255 alpha:1.0];
    return box;
}

+(AlertBox*)showAlertFor:(id)parent
             withTitle:(NSString*)title
             withMessage:(NSString*)message
              leftButton:(NSString*)leftButton
             rightButton:(NSString*)rightButton
              leftAction:(SEL)leftAction
             rightAction:(SEL)rightAction {
    
    AlertBox* alertBox = [[AlertBox alloc] initWithNibName:@"AlertBox" bundle:nil];
    
    alertBox.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    alertBox.view.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
    
    
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    
    [topController.view addSubview:alertBox.view];
    [topController addChildViewController:alertBox];
    [alertBox didMoveToParentViewController:topController];
    
    alertBox.rightAction = rightAction;
    alertBox.leftAction = leftAction;
    
    
    alertBox.alertTitle.text = title;
    alertBox.alertMessage.text = message;
    
    if (leftButton) {
        [alertBox.leftButton setTitle:[leftButton uppercaseString] forState:UIControlStateNormal];
    } else {
        [alertBox.leftButton setHidden:YES];
    }
    
    if (rightButton) {
        [alertBox.rightButton setTitle:[rightButton uppercaseString] forState:UIControlStateNormal];
     } else {
        [alertBox.rightButton setHidden:YES];

     }
    
    [alertBox.rightButton addTarget:alertBox action:@selector(rightButtonPlaceholder) forControlEvents:UIControlEventTouchDown];
    [alertBox.leftButton addTarget:alertBox action:@selector(leftButtonPlaceholder) forControlEvents:UIControlEventTouchDown];
    
    alertBox.parentObject = parent;
    alertBox.topController = topController;
    return alertBox;
}

@end
