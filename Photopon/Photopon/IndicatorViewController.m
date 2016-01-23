//
//  IndicatorViewController.m
//  Photopon
//
//  Created by Hayk Hayotsyan on 20/1/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import "IndicatorViewController.h"

@interface IndicatorViewController ()

@end

@implementation IndicatorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)remove {
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}


-(void)hide {
    self.doneIndicator.center = self.activityIndicator.center;
    self.activityIndicator.hidden = YES;
    self.doneIndicator.hidden = NO;
    
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(remove) userInfo:nil repeats:NO];
}


+(IndicatorViewController*)showIndicator:(UIViewController*)parent withText:(NSString*)text timeout:(NSInteger)timeout {

    IndicatorViewController* indController = [[IndicatorViewController alloc] initWithNibName:@"IndicatorViewController" bundle:nil];

    indController.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 80);
    indController.view.center = parent.view.center;

    [parent.view addSubview:indController.view];
    [parent addChildViewController:indController];
    [indController didMoveToParentViewController:parent];
    
    indController.activityDescription.text = text;
    [indController.activityIndicator startAnimating];
    
    indController.timoutTimer = [NSTimer scheduledTimerWithTimeInterval:timeout target:indController selector:@selector(hide) userInfo:nil repeats:NO];
    indController.parentController = parent;
    
    
    return indController;
}



@end
