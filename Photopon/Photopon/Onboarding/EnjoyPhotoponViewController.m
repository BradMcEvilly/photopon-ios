//
//  EnjoyPhotoponViewController.m
//  Photopon
//
//  Created by Ante Karin on 11/09/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import "EnjoyPhotoponViewController.h"
#import "PPTools.h"
#import "AlertControllerFactory.h"

@interface EnjoyPhotoponViewController()

@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UIButton *tryItOutButton;

@end

@implementation EnjoyPhotoponViewController 

-(void)viewDidLoad {
    [super viewDidLoad];

    for (UIButton *button in @[self.registerButton, self.tryItOutButton]) {
        button.layer.cornerRadius = 7;
        button.layer.masksToBounds = YES;
    }
}

-(void) checkLocation{
    
        UIAlertController *alert = [AlertControllerFactory basicConfirmWithMessage:@"In order to access the app you must enable your location services!" completion:^{
            [PPTools enableLocation:nil];
        }];
        [self presentViewController:alert animated:YES completion:^{
            
        }];
    
}

- (IBAction)registerButtonHandler:(id)sender {
    
    if([PPTools isLocationEnabled] != 2){
        [self checkLocation];
    }else{
         [self.delegate userShouldRegister];
    }
   
}

- (IBAction)skipButtonHandler:(id)sender {
    if([PPTools isLocationEnabled] != 2){
        [self checkLocation];
    }else{
        [self.delegate userShouldSkip];
    }
//    [[[UIAlertView alloc]initWithTitle:@"NOT IMPLEMENTED" message:@"-" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
}

@end
