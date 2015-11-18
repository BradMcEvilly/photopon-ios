//
//  MerchantInfoPage.h
//  Photopon
//
//  Created by Hayk Hayotsyan on 18/11/15.
//  Copyright © 2015 Photopon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MerchantInfoPage : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *infoBusinessName;
@property (weak, nonatomic) IBOutlet UITextField *infoTaxID;
@property (weak, nonatomic) IBOutlet UITextField *infoBusinessPhone;

@property (weak, nonatomic) IBOutlet UIButton *requestMerchant;
@end
