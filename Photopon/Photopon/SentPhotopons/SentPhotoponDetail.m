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
    
    
    [HeaderViewController addBackHeaderToView:self withTitle:@"Photopon Details"];
    
    
    [self.sentPhotoponUsers setDelegate:self];
    [self.sentPhotoponUsers setDataSource:self];
    
    
    
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
    [messageCtrl setMessage: @"Hurry up. Open my Photopon to receive your gift!"];
    
    [self presentViewController:messageCtrl animated:YES completion:nil];
    
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
            [AlertBox showAlertFor:self withTitle:@"Error" withMessage:@"Failed to send SMS message" leftButton:nil rightButton:@"OK" leftAction:nil rightAction:nil];
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
        
        [AlertBox showAlertFor:self withTitle:@"Error" withMessage:@"Your device doesn't support SMS!" leftButton:nil rightButton:@"OK" leftAction:nil rightAction:nil];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SentPhotoponsList"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"SentPhotoponsList"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    id item = [sentPhotoponUserList objectAtIndex:indexPath.row];
    BOOL isPlaceholder = [item isKindOfClass:[PFUserPlaceholder class]];
    
    
    cell.textLabel.text = [item username];
    cell.detailTextLabel.text = @"Loading...";
    
    
    if (!isPlaceholder) {
        
        [[PhotoponWrapper fromObject:photopon] getStatusForUser:item withBlock:^(NSString *status) {
            cell.detailTextLabel.text = status;
            if ([status isEqualToString:@"Notified"] || [status isEqualToString:@"Saved"]) {
                
                
                UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
                CGRect frame = CGRectMake(0.0, 0.0, 20, 20);
                button.frame = frame;
                
                UIImage * buttonImage = [UIImage imageNamed:@"Icon-Speach-Bubble.png"];
                
                [button setImage:buttonImage forState:UIControlStateNormal];
                button.tag = indexPath.row;
                [button addTarget:self action:@selector(nudgeUser:event:)  forControlEvents:UIControlEventTouchUpInside];
                button.backgroundColor = [UIColor clearColor];
                cell.accessoryView = button;
            }
            
        }];
    } else {
        cell.detailTextLabel.text = @"Not registered yet.";
    }
    
    if (!isPlaceholder) {
        PFFile* imgObj = [item objectForKey:@"image"];
        NSString* img = imgObj.url;
        

        
        if (img) {
            [cell.imageView sd_setImageWithURL:[NSURL URLWithString:img] placeholderImage:[UIImage imageNamed:@"Icon-Administrator.png"]  options:SDWebImageAvoidAutoSetImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [cell.imageView setImage:image];
                    
                    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
                    
                });
                
            }];
        } else {
            [cell.imageView setImage:[UIImage imageNamed:@"Icon-Administrator.png"]];
            
        }
    } else {
        
        [cell.imageView setImage:[UIImage imageNamed:@"Icon-Phone-2.png"]];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        CGRect frame = CGRectMake(0.0, 0.0, 20, 20);
        button.frame = frame;
        
        UIImage * buttonImage = [UIImage imageNamed:@"Icon-Speach-Bubble.png"];
        
        [button setImage:buttonImage forState:UIControlStateNormal];
        button.tag = indexPath.row;
        [button addTarget:self action:@selector(nudgeSmsUser:event:)  forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor = [UIColor clearColor];
        cell.accessoryView = button;
    }
    
    return cell;
}


@end
