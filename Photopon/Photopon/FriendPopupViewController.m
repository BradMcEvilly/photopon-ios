//
//  FriendPopupViewController.m
//  Photopon
//
//  Created by Hayk Hayotsyan on 4/12/15.
//  Copyright © 2015 Photopon. All rights reserved.
//

#import <Parse/Parse.h>
#import "FriendPopupViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ChatMessagesController.h"

@interface FriendPopupViewController ()

@end

@implementation FriendPopupViewController
{
    NSDictionary* selectedFriend;
    FriendsViewController* friendViewCtrl;
}





-(void)viewWillAppear:(BOOL)animated {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"FriendPopupScreen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:singleFingerTap];
    
    
    UITapGestureRecognizer *friendPopupTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(friendPopupTapped:)];
    [self.friendContent addGestureRecognizer:friendPopupTap];
    
    
    NSString* img = [selectedFriend objectForKey:@"image"];

    [self.friendPicture sd_setImageWithURL:[NSURL URLWithString:img] placeholderImage:[UIImage imageNamed:@"profileplaceholder.png"]];
    
    self.friendName.text = [selectedFriend objectForKey:@"name"];
    self.friendDescription.text = [selectedFriend objectForKey:@"email"];
    
    
    
/*
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.friendPicture.bounds];
    self.friendPicture.layer.masksToBounds = YES;
    self.friendPicture.layer.shadowColor = [UIColor blackColor].CGColor;
    self.friendPicture.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
    self.friendPicture.layer.shadowOpacity = 0.5f;
    self.friendPicture.layer.shadowPath = shadowPath.CGPath;
*/
    
    self.chatButton.image = nil;
    self.couponButton.image = nil;
    self.settingButton.image = nil;

    [self.chatButton setDefaultIconIdentifier:@"fa-comments"];
    [self.couponButton setDefaultIconIdentifier:@"fa-gift"];
    [self.settingButton setDefaultIconIdentifier:@"fa-cogs"];
    
    
    self.chatButton.defaultView.textColor = [UIColor colorWithRed:1.0/255 green:152.0/255 blue:225.0/255 alpha:1];
    self.chatButton.defaultView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    
    self.couponButton.defaultView.textColor = [UIColor colorWithRed:199.0/255 green:97.0/255 blue:20.0/255 alpha:1];
    self.couponButton.defaultView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    
    self.settingButton.defaultView.textColor = [UIColor colorWithRed:136.0/255 green:136.0/255 blue:136.0/255 alpha:1];
    self.settingButton.defaultView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    

    
    
    UITapGestureRecognizer *chatButtonTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(startChat:)];
    [self.chatButton addGestureRecognizer:chatButtonTap];
    self.chatButton.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *sentPhotopon = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sentPhotopon:)];
    [self.couponButton addGestureRecognizer:sentPhotopon];
    self.couponButton.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *settingsButtonTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showSettings:)];
    [self.settingButton addGestureRecognizer:settingsButtonTap];
    self.settingButton.userInteractionEnabled = YES;

    
    
    [self.friendContent.layer setBorderColor: [[UIColor blackColor] CGColor]];
    [self.friendContent.layer setBorderWidth: 0.2];
    
    [self.friendPicture.layer setBorderColor: [[UIColor blackColor] CGColor]];
    [self.friendPicture.layer setBorderWidth: 0.2];
}


- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:[recognizer.view superview]];
    [self dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"single tap %f, %f", location.x, location.y);
}



- (void)friendPopupTapped:(UITapGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:[recognizer.view superview]];
    NSLog(@"friend tap %f, %f", location.x, location.y);
}

-(void)setFriend:(NSDictionary*)friendObject {
    selectedFriend = friendObject;
}

-(void)setFriendViewController:(FriendsViewController*)ctrl {
    friendViewCtrl = ctrl;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(BOOL)askToInviteIfNeeded {
    if (![selectedFriend valueForKey:@"isPlaceholder"]) {
        return FALSE;
    }
    
    UIAlertController* confirmationAlert = [UIAlertController alertControllerWithTitle:@"Send Invite"
                                                                               message:[NSString stringWithFormat:@"Your friend %@ is not registered in Photopon. Would you like to invite him?", [selectedFriend valueForKey:@"name"]]
                                                                        preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* getAction = [UIAlertAction actionWithTitle:@"Invite" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
    
    }];
    
    
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Not now" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
    
    [confirmationAlert addAction:getAction];
    [confirmationAlert addAction:cancelAction];
    [self presentViewController:confirmationAlert animated:YES completion:nil];
    return TRUE;
}


-(void)startChat:(UITapGestureRecognizer *)recognizer {
    if ([self askToInviteIfNeeded]) {
        return;
    }
    
    [self dismissViewControllerAnimated:NO completion:^{
        
        
    }];
    
    
  ChatMessagesController* messageCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"SBMessages"];
  [messageCtrl setUser: selectedFriend[@"object"]];
  [friendViewCtrl showViewController:messageCtrl sender:nil];
    
    NSLog(@"Start Chazt");
}

-(void)sentPhotopon:(UITapGestureRecognizer *)recognizer {
    if ([self askToInviteIfNeeded]) {
        return;
    }
    
    NSLog(@"Send Photopon");
}



-(void) removeFriendShip {
    NSString* objId = [selectedFriend objectForKey:@"friendshipId"];
    
    
    // This is workaround for Prase bug when object is not removed when it is gone from memory before block function finishes
    __block PFObject* dummyFriendshipRef = nil;
    
    PFQuery *query = [PFQuery queryWithClassName:@"Friends"];
    [query getObjectInBackgroundWithId:objId block:^(PFObject *friendship, NSError *error) {
        if (friendship) {
            [friendship deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                dummyFriendshipRef = friendship;
                [friendViewCtrl updateFriends];
                [self dismissViewControllerAnimated:YES completion:nil];

            }];
        }
    }];
    
}


-(void)showSettings:(UITapGestureRecognizer *)recognizer {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *blockAction = [UIAlertAction actionWithTitle:@"Block" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // this block runs when the driving option is selected
    }];
    
    UIAlertAction *unfriendAction = [UIAlertAction actionWithTitle:@"Unfriend" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self removeFriendShip];
    }];
    
    UIAlertAction *ignoreAction = [UIAlertAction actionWithTitle:@"Ignore" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // this block runs when the walking option is selected
    }];
    
    
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:blockAction];
    [alert addAction:unfriendAction];
    [alert addAction:ignoreAction];
    [alert addAction:defaultAction];
    
    alert.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    alert.popoverPresentationController.sourceView = self.settingButton;
    alert.popoverPresentationController.sourceRect = CGRectMake(20, 40, 10, 10);
    

    [self presentViewController:alert animated:YES completion:nil];

}


@end
