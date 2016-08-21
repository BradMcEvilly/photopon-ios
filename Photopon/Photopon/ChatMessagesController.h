//
//  ChatMessagesController.h
//  Photopon
//
//  Created by Hayk Hayotsyan on 18/8/15.
//  Copyright (c) 2015 Photopon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <PubNub/PNObjectEventListener.h>


@interface ChatMessagesController : UIViewController<PNObjectEventListener, UITableViewDataSource, UITableViewDelegate>

- (void)setUser:(PFUser*)user;
- (void)setMessage:(NSString*)message;

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UITableView *chatTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;


@property (strong, nonatomic) IBOutlet UIView *mainView;

@end
