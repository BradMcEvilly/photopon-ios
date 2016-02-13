//
//  HeaderViewController.h
//  Photopon
//
//  Created by Hayk Hayotsyan on 15/1/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITheme.h"

@interface HeaderViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *titleText;
@property (weak, nonatomic) IBOutlet UIButton *leftMenuButton;
@property (weak, nonatomic) IBOutlet UIButton *rightMenuButton;
@property (weak, nonatomic) IBOutlet UIView *angledShade;

+(HeaderViewController*)addHeaderToView:(UIViewController*)view withTitle:(NSString*)headerText;
+(HeaderViewController*)addBackHeaderToView:(UIViewController*)viewCtrl withTitle:(NSString*)headerText;

-(void)addRightButtonWithImage:(NSString*)icon withTarget:(id)target action:(SEL)action;
-(void)setTheme:(UITheme*)theme;

@end
