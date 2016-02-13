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
#import <MessageUI/MessageUI.h>


@interface FriendPopupViewController : UIViewController<MFMessageComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *friendContent;
@property (weak, nonatomic) IBOutlet UIImageView *friendPicture;

@property (weak, nonatomic) IBOutlet UILabel *friendName;
@property (weak, nonatomic) IBOutlet UILabel *friendDescription;


@property (weak, nonatomic) IBOutlet UIImageView *chatButton;
@property (weak, nonatomic) IBOutlet UIImageView *couponButton;
@property (weak, nonatomic) IBOutlet UIImageView *settingButton;



-(void)setFriend:(NSDictionary*)friendObject;
-(void)setFriendViewController:(FriendsViewController*)ctrl;

@end
