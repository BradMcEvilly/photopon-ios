//
//  SentPhotoponDetail.h
//  Photopon
//
//  Created by Hayk Hayotsyan on 9/8/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>


@interface SentPhotoponDetail : UIViewController<UITableViewDataSource, UITableViewDelegate, MFMessageComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *sentPhotoponUsers;

-(void) setPhotopon: (PFObject*)photoponObject;


@end
