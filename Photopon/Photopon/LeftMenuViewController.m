//
//  LeftMenuViewController.m
//  Photopon
//
//  Created by Hayk Hayotsyan on 15/12/15.
//  Copyright © 2015 Photopon. All rights reserved.
//

#import "LeftMenuViewController.h"

@interface LeftMenuViewController ()

@end

@implementation LeftMenuViewController

{
    CGRect originalFrame;
    CGRect hiddenFrame;
    MenuHookType clientHook;

    NSMutableArray *itemTags;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    itemTags = [[NSMutableArray alloc] init];
    
    
    originalFrame = CGRectMake(0, 0, 250, [UIScreen mainScreen].bounds.size.height);
    hiddenFrame = CGRectMake(-250, 0, 250, [UIScreen mainScreen].bounds.size.height);
    self.menuView.frame = hiddenFrame;
    
    
    
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeLeftMenu)];
    [self.mainView addGestureRecognizer:singleFingerTap];
    
    
    
    UITapGestureRecognizer *menuTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(menuTapped:)];
    [self.menuView addGestureRecognizer:menuTap];
    
    
    [self addTapHandlerFor:self.notificationItem withTag:@"notifications"];
    [self addTapHandlerFor:self.friendsItem withTag:@"friends"];
    [self addTapHandlerFor:self.couponsItem withTag:@"coupons"];
    [self addTapHandlerFor:self.walletItem withTag:@"wallet"];
    [self addTapHandlerFor:self.settingsItem withTag:@"settings"];
    [self addTapHandlerFor:self.signoutItem withTag:@"signout"];
    [self addTapHandlerFor:self.addPhotoponItem withTag:@"addphotopon"];
    
}




-(void)viewWillAppear:(BOOL)animated {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"LeftMenu"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}




-(void)addTapHandlerFor:(UIView*)view withTag:(NSString*)tag {
    view.tag = [itemTags count];
    [itemTags addObject:tag];
    
    
    UITapGestureRecognizer *menuItemTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(menuItemTapped:)];
    [view addGestureRecognizer:menuItemTap];

}


- (void)closeLeftMenu {
    
    [UIView animateWithDuration:0.25 animations:^{
        self.menuView.frame = hiddenFrame;
    } completion:^(BOOL finished) {
        if (finished) {
            [self dismissViewControllerAnimated:NO completion:nil];
        }
    }];
}



- (void)menuItemTapped:(UITapGestureRecognizer *)recognizer {
    NSInteger tag = recognizer.view.tag;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.menuView.frame = hiddenFrame;
    } completion:^(BOOL finished) {
        if (finished) {
            [self dismissViewControllerAnimated:NO completion:nil];
        }
        if (clientHook) {
            clientHook(itemTags[tag]);
        }

    }];

//    [self closeLeftMenu];
}


- (void)menuTapped:(UITapGestureRecognizer *)recognizer {
    
}


- (void) onClickHook:(MenuHookType)hook {
    clientHook = hook;
}



- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [UIView animateWithDuration:0.25 animations:^{
         self.menuView.frame = originalFrame;
     }];
}


- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    self.menuView.frame = hiddenFrame;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
