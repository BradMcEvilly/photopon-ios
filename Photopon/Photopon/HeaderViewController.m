//
//  HeaderViewController.m
//  Photopon
//
//  Created by Hayk Hayotsyan on 15/1/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import "HeaderViewController.h"
#import "LeftMenuViewController.h"

@interface HeaderViewController ()

@end

@implementation HeaderViewController

{
    UIStatusBarStyle styleBeforeMe;
    UIStatusBarStyle styleForMe;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.angledShade.transform = CGAffineTransformRotate(self.angledShade.transform, M_PI / 4);
    
    styleForMe = UIStatusBarStyleDefault;
}

-(void)viewWillDisappear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarStyle:styleBeforeMe];
}

-(void)viewWillAppear:(BOOL)animated {
    styleBeforeMe = [UIApplication sharedApplication].statusBarStyle;

}



-(void)viewDidAppear:(BOOL)animated {
 
    [[UIApplication sharedApplication] setStatusBarStyle:styleForMe];
    
}


-(void)backMenuClicked {
    if (self.parentViewController.navigationController) {
        [self.parentViewController.navigationController popViewControllerAnimated:YES];
    } else {
        [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
    }
}


-(void)leftMenuClicked {
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    LeftMenuViewController* leftMenu = (LeftMenuViewController*)[storyBoard instantiateViewControllerWithIdentifier:@"SBLeftMenu"];
    
    leftMenu.providesPresentationContextTransitionStyle = YES;
    leftMenu.definesPresentationContext = YES;
    
    [leftMenu onClickHook:^(NSString *menuItem) {
       
        
        if ([menuItem isEqualToString:@"notifications"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Goto_Notifications" object:nil];
        }
        
        if ([menuItem isEqualToString:@"friends"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Goto_Friends" object:nil];
        }
        
        if ([menuItem isEqualToString:@"coupons"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Goto_Coupons" object:nil];
        }
        
        if ([menuItem isEqualToString:@"wallet"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Goto_Wallet" object:nil];
        }
        
        if ([menuItem isEqualToString:@"addphotopon"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Goto_AddPhotopon" object:nil];
        }
        
        
        
        if ([menuItem isEqualToString:@"settings"]) {
            UIViewController *settings = [storyBoard instantiateViewControllerWithIdentifier:@"SBSettings"];
            [self presentViewController:settings animated:true completion:nil];

        }
        
        if ([menuItem isEqualToString:@"signout"]) {
            [PFUser logOut];
            UIViewController* loginCtrl = [storyBoard instantiateViewControllerWithIdentifier:@"LoginCtrl"];
            [self presentViewController:loginCtrl animated:true completion:nil];
        }
        
    }];
    
    
    
    [leftMenu setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    [self presentViewController:leftMenu animated:NO completion:nil];

}







+(HeaderViewController*)addHeaderToView:(UIViewController*)viewCtrl withTitle:(NSString*)headerText {
    HeaderViewController* headerViewController = [[HeaderViewController alloc] initWithNibName:@"HeaderViewController" bundle:nil];
    
    headerViewController.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 70);
    
    [viewCtrl.view addSubview:headerViewController.view];
    [viewCtrl addChildViewController:headerViewController];
    [headerViewController didMoveToParentViewController:viewCtrl];
    
    headerViewController.titleText.text = headerText;

    [headerViewController.leftMenuButton setTitle:@"" forState:UIControlStateNormal];

    [headerViewController.leftMenuButton addTarget:headerViewController action:@selector(leftMenuClicked) forControlEvents:UIControlEventTouchDown];
    return headerViewController;
}


+(HeaderViewController*)addBackHeaderToView:(UIViewController*)viewCtrl withTitle:(NSString*)headerText {
    HeaderViewController* headerViewController = [[HeaderViewController alloc] initWithNibName:@"HeaderViewController" bundle:nil];
    
    headerViewController.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 70);
    
    [viewCtrl.view addSubview:headerViewController.view];
    [viewCtrl addChildViewController:headerViewController];
    [headerViewController didMoveToParentViewController:viewCtrl];
    
    headerViewController.titleText.text = headerText;
    [headerViewController.leftMenuButton setTitle:@"" forState:UIControlStateNormal];
    
    
    [headerViewController.leftMenuButton setBackgroundImage:[UIImage imageNamed:@"Icon-Left-2.png"] forState:UIControlStateNormal];
    
    [headerViewController.leftMenuButton addTarget:headerViewController action:@selector(backMenuClicked) forControlEvents:UIControlEventTouchDown];
    return headerViewController;
}


-(void)addRightButtonWithImage:(NSString*)imageName withTarget:(id)target action:(SEL)action {
    
    [self.rightMenuButton setHidden:NO];
    [self.rightMenuButton setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [self.rightMenuButton addTarget:target action:action forControlEvents:UIControlEventTouchDown];
}

-(void)setTheme:(UITheme*)theme {
    [self.view setBackgroundColor:theme.headerColor];
    
    [self.leftMenuButton setTitleColor:theme.headerTextColor forState:UIControlStateNormal];
    [self.rightMenuButton setTitleColor:theme.headerTextColor forState:UIControlStateNormal];
    [self.titleText setTextColor:theme.headerTextColor];
    
    UIImage* i = MaskImageWithColor(self.leftMenuButton.currentBackgroundImage, theme.headerTextColor);
    [self.leftMenuButton setBackgroundImage:i forState:UIControlStateNormal];
    
    if (self.rightMenuButton.currentBackgroundImage) {
        UIImage* ri = MaskImageWithColor(self.rightMenuButton.currentBackgroundImage, theme.headerTextColor);
        [self.rightMenuButton setBackgroundImage:ri forState:UIControlStateNormal];

    }
    styleForMe = UIStatusBarStyleLightContent;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
