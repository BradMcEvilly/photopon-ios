//
//  SentPhotoponDetail.h
//  Photopon
//
//  Created by Hayk Hayotsyan on 9/8/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SentPhotoponDetail : UIViewController<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *sentPhotoponUsers;

-(void) setPhotopon: (PFObject*)photoponObject;


@end
