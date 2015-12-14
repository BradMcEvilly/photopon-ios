//
//  FriendPopupViewController.h
//  Photopon
//
//  Created by Hayk Hayotsyan on 4/12/15.
//  Copyright © 2015 Photopon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FontAwesome/FAImageView.h>
#import "FriendsViewController.h"

@interface FriendPopupViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *friendContent;
@property (weak, nonatomic) IBOutlet UIImageView *friendPicture;

@property (weak, nonatomic) IBOutlet UILabel *friendName;
@property (weak, nonatomic) IBOutlet UILabel *friendDescription;


@property (weak, nonatomic) IBOutlet FAImageView *chatButton;
@property (weak, nonatomic) IBOutlet FAImageView *couponButton;
@property (weak, nonatomic) IBOutlet FAImageView *settingButton;



-(void)setFriend:(NSDictionary*)friendObject;
-(void)setFriendViewController:(FriendsViewController*)ctrl;

@end
