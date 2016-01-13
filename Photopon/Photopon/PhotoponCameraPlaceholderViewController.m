//
//  PhotoponCameraPlaceholderViewController.m
//  Photopon
//
//  Created by Hayk Hayotsyan on 12/1/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import "PhotoponCameraPlaceholderViewController.h"
#import "PhotoponCameraView.h"

@interface PhotoponCameraPlaceholderViewController ()

@end

@implementation PhotoponCameraPlaceholderViewController
{
    MainController* parentCtrl;
}



- (UIViewController*) topMostController {
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}



-(void)setPageViewController:(MainController*)parent {
    parentCtrl = parent;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    PhotoponCameraView* mainCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"SBPhotoponCam"];
    [mainCtrl setPageViewController:parentCtrl];
    [[self topMostController] presentViewController:mainCtrl animated:true completion:nil];

    
}
@end
