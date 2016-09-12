//
//  EnjoyPhotoponViewController.m
//  Photopon
//
//  Created by Ante Karin on 11/09/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import "EnjoyPhotoponViewController.h"

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

- (IBAction)registerButtonHandler:(id)sender {

}

- (IBAction)skipButtonHandler:(id)sender {
    
}

@end
