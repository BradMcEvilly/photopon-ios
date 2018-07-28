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
#import "UITheme.h"
#import "AlertBox.h"

@interface FriendPopupViewController ()

@end

@implementation FriendPopupViewController
{
    PFUser* selectedFriend;
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
    
    
    PFFile* img = [selectedFriend objectForKey:@"image"];
    if (img) {
        [self.friendPicture sd_setImageWithURL:[NSURL URLWithString:img.url] placeholderImage:[UIImage imageNamed:@"Icon-Administrator.png"]];
    }
    
    self.friendName.text = [selectedFriend objectForKey:@"name"];
    if (!self.friendName.text) {
        self.friendName.text = selectedFriend[@"username"];
    }
    self.friendDescription.text = [selectedFriend objectForKey:@"email"];
    
    
    
/*
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.friendPicture.bounds];
    self.friendPicture.layer.masksToBounds = YES;
    self.friendPicture.layer.shadowColor = [UIColor blackColor].CGColor;
    self.friendPicture.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
    self.friendPicture.layer.shadowOpacity = 0.5f;
    self.friendPicture.layer.shadowPath = shadowPath.CGPath;
*/
    
    //[self.chatButton setDefaultIconIdentifier:@"fa-comments"];
    //[self.couponButton setDefaultIconIdentifier:@"fa-gift"];
    //[self.settingButton setDefaultIconIdentifier:@"fa-cogs"];
    
//    [self.chatButton setImage:MaskImageWithColor(self.chatButton.image, [UITheme blueTheme].headerColor)];
//    [self.couponButton setImage:MaskImageWithColor(self.couponButton.image, [UITheme orangeTheme].headerColor)];
//    [self.settingButton setImage:MaskImageWithColor(self.settingButton.image, [UITheme blackTheme].headerColor)];
//    

    
    
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


- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            SendGAEvent(@"user_action", @"friend_popup", @"invite_message_cancelled");

            break;
            
        case MessageComposeResultFailed:
        {
            [AlertBox showAlertFor:self withTitle:@"Ups something went wrong..." withMessage:@"Failed to send SMS message" leftButton:nil rightButton:@"OK" leftAction:nil rightAction:nil];
            SendGAEvent(@"user_action", @"friend_popup", @"invite_message_failed");

            break;
        }
            
        case MessageComposeResultSent:
            SendGAEvent(@"user_action", @"friend_popup", @"invite_message_sent");

            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)InviteFriend {
    SendGAEvent(@"user_action", @"friend_popup", @"invite_clicked");
    
    
    if(![MFMessageComposeViewController canSendText]) {
        
        [AlertBox showAlertFor:self withTitle:@"Ups something went wrong..." withMessage:@"Your device doesn't support SMS!" leftButton:nil rightButton:@"OK" leftAction:nil rightAction:nil];
        SendGAEvent(@"user_action", @"friend_popup", @"send_text_failed");
        
        return;
    }
    
    NSArray *recipents = @[selectedFriend[@"id"]];
    NSString *message = @"I have sent you Photopon. To redeem it install Photopon app and click on notification. https://goo.gl/emLbil";
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setRecipients:recipents];
    [messageController setBody:message];
    
    [self presentViewController:messageController animated:YES completion:nil];
}



-(BOOL)askToInviteIfNeeded {
    if (![selectedFriend valueForKey:@"isPlaceholder"]) {
        return FALSE;
    }
    
    SendGAEvent(@"user_action", @"friend_popup", @"ask_to_invite_popup");

    [AlertBox showAlertFor:self
                 withTitle:@"Send Invite"
               withMessage:[NSString stringWithFormat:@"Your friend %@ is not registered to Photopon. Would you like to invite him?", [selectedFriend valueForKey:@"name"]]
                leftButton:@"Invite"
               rightButton:@"Not now"
                leftAction:@selector(InviteFriend)
               rightAction:nil];
    
    return TRUE;
}

 
-(void)startChat:(UITapGestureRecognizer *)recognizer {
    if ([self askToInviteIfNeeded]) {
        return;
    }
    
    [self dismissViewControllerAnimated:NO completion:^{
        
    }];
    
    
    ChatMessagesController* messageCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"SBMessages"];
    [messageCtrl setUser: selectedFriend];

    [friendViewCtrl.navigationController pushViewController:messageCtrl animated:YES];
    SendGAEvent(@"user_action", @"friend_popup", @"chat_started");

    NSLog(@"Start Chat");
}

-(void)sentPhotopon:(UITapGestureRecognizer *)recognizer {
    if ([self askToInviteIfNeeded]) {
        return;
    }

    [self dismissViewControllerAnimated:YES completion:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Goto_AddPhotopon" object:nil userInfo:@{
          @"friendId": selectedFriend.objectId}];
    
    SendGAEvent(@"user_action", @"friend_popup", @"send_photopon");
}



-(void) removeFriendShip {
    NSString* objId = selectedFriend.objectId;
    
    
    // This is workaround for Prase bug when object is not removed when it is gone from memory before block function finishes
    __block PFObject* dummyFriendshipRef = nil;
    
    PFQuery *query = [PFQuery queryWithClassName:@"Friends"];
    [query whereKey:@"user1" equalTo:[PFUser currentUser]];
    [query whereKey:@"user2" equalTo:selectedFriend];
    [query setLimit:1];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        
        
         if (objects.count > 0) {
             PFObject *friendship = objects[0];
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
    
    SendGAEvent(@"user_action", @"friend_popup", @"settings_opened");
    /*
    UIAlertAction *blockAction = [UIAlertAction actionWithTitle:@"Block" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // this block runs when the driving option is selected
       SendGAEvent(@"user_action", @"friend_popup", @"block_action");
    }];
     */
    
    UIAlertAction *unfriendAction = [UIAlertAction actionWithTitle:@"Unfriend" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        SendGAEvent(@"user_action", @"friend_popup", @"unfriend_action");

        [self removeFriendShip];
    }];
    
    /*
    UIAlertAction *ignoreAction = [UIAlertAction actionWithTitle:@"Ignore" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        SendGAEvent(@"user_action", @"friend_popup", @"ignore_action");

        // this block runs when the walking option is selected
    }];
    */
    
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
   // [alert addAction:blockAction];
    [alert addAction:unfriendAction];
    //[alert addAction:ignoreAction];
    [alert addAction:defaultAction];
    
    alert.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    alert.popoverPresentationController.sourceView = self.settingButton;
    alert.popoverPresentationController.sourceRect = CGRectMake(20, 40, 10, 10);
    

    [self presentViewController:alert animated:YES completion:nil];

}


@end
