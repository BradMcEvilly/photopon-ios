//
//  SentPhotoponDetail.m
//  Photopon
//
//  Created by Hayk Hayotsyan on 9/8/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import "SentPhotoponDetail.h"

#import "HeaderViewController.h"
#import "DBAccess.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "PhotoponWrapper.h"
#import "ChatMessagesController.h"
#import "AlertBox.h"
#import "SentPhotoponDetailsCell.h"

@implementation SentPhotoponDetail
{
    NSMutableArray *sentPhotoponUserList;
    PFObject* photopon;
}

-(void) setPhotopon: (PFObject*)photoponObject {
    photopon = photoponObject;
}

-(void)viewDidLoad
{
    [super viewDidLoad];

    [self.sentPhotoponUsers setDelegate:self];
    [self.sentPhotoponUsers setDataSource:self];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    [[PhotoponWrapper fromObject:photopon] grabUsers:^(NSArray *results) {
        sentPhotoponUserList = [NSMutableArray arrayWithArray:results];
        [self.sentPhotoponUsers reloadData];
    }];

    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [sentPhotoponUserList count];
}


-(void)nudgeUser:(id)sender event:(id)event {
    
    ChatMessagesController* messageCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"SBMessages"];
    UIButton* thisButton = sender;
    
    PFUser* selectedFriend = [sentPhotoponUserList objectAtIndex:thisButton.tag];
    [messageCtrl setUser: selectedFriend];
    [messageCtrl setMessage: @"Hurry up! Open my Photopon to receive my gift."];
    
    [self.navigationController pushViewController:messageCtrl animated:YES];
    
    SendGAEvent(@"user_action", @"sent_photopon_detail_nudge", @"chat_started");
    
    NSLog(@"Start Chat");

    
}


- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            SendGAEvent(@"user_action", @"sent_photopon_detail_nudge", @"invite_message_cancelled");
            
            break;
            
        case MessageComposeResultFailed:
        {
            [AlertBox showAlertFor:self withTitle:@"Ups something went wrong..." withMessage:@"Failed to send SMS message" leftButton:nil rightButton:@"OK" leftAction:nil rightAction:nil];
            SendGAEvent(@"user_action", @"sent_photopon_detail_nudge", @"invite_message_failed");
            
            break;
        }
            
        case MessageComposeResultSent:
            SendGAEvent(@"user_action", @"sent_photopon_detail_nudge", @"invite_message_sent");
            
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)nudgeSmsUser:(id)sender event:(id)event {
    
    UIButton* thisButton = sender;
    
    PFUserPlaceholder* selectedFriend = [sentPhotoponUserList objectAtIndex:thisButton.tag];

    
    SendGAEvent(@"user_action", @"sent_photopon_detail_nudge", @"nudge_sms");
    
    
    if(![MFMessageComposeViewController canSendText]) {
        
        [AlertBox showAlertFor:self withTitle:@"Ups something went wrong..." withMessage:@"Your device doesn't support SMS!" leftButton:nil rightButton:@"OK" leftAction:nil rightAction:nil];
        SendGAEvent(@"user_action", @"sent_photopon_detail_nudge", @"send_text_failed");
        
        return;
    }
    
    NSArray *recipents = @[ [selectedFriend getId] ];
    NSString *message = @"Hurry up. Join Photopon to receive my gift!";
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setRecipients:recipents];
    [messageController setBody:message];
    
    [self presentViewController:messageController animated:YES completion:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SentPhotoponDetailsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SentPhotoponDetailsCell"];

    id item = [sentPhotoponUserList objectAtIndex:indexPath.row];
    BOOL isPlaceholder = [item isKindOfClass:[PFUserPlaceholder class]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.titleLabel.text = [item username];
    cell.subtitleLabel.text = @"Loading...";
    cell.nudgeButton.hidden = YES;
    if (!isPlaceholder) {
        
        [[PhotoponWrapper fromObject:photopon] getStatusForUser:item withBlock:^(NSString *status) {
            cell.subtitleLabel.text = status;
            if ([status isEqualToString:@"Notified"] || [status isEqualToString:@"Saved"]) {

                cell.nudgeButton.tag = indexPath.row;
                [cell.nudgeButton addTarget:self action:@selector(nudgeUser:event:)  forControlEvents:UIControlEventTouchUpInside];
                cell.nudgeButton.hidden = NO;
            }
            
        }];
    } else {
        cell.subtitleLabel.text = @"Not registered yet.";
    }
    
    if (!isPlaceholder) {
        PFFile* imgObj = [item objectForKey:@"image"];
        NSString* img = imgObj.url;

        if (img) {
            [cell.avatarImageView sd_setImageWithURL:[NSURL URLWithString:img] placeholderImage:[UIImage imageNamed:@"Icon-Administrator.png"]  options:SDWebImageAvoidAutoSetImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [cell.avatarImageView setImage:image];
                    cell.avatarImageView.contentMode = UIViewContentModeScaleAspectFit;
                });
                
            }];
        } else {
            [cell.avatarImageView setImage:[UIImage imageNamed:@"Icon-Administrator.png"]];

        }
    } else {
        
        [cell.avatarImageView setImage:[UIImage imageNamed:@"Icon-Phone-2.png"]];
        
        cell.nudgeButton.tag = indexPath.row;
        [cell.nudgeButton addTarget:self action:@selector(nudgeSmsUser:event:) forControlEvents:UIControlEventTouchUpInside];
        cell.nudgeButton.hidden = NO;
    }

    return cell;
}


@end
