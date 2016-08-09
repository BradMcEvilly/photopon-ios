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



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SentPhotoponsList"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"SentPhotoponsList"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    PFUser *item = [sentPhotoponUserList objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [item username];
    cell.detailTextLabel.text = @"Loading...";

    PFFile* imgObj = [item objectForKey:@"image"];
    NSString* img = imgObj.url;
    
    
    
    [[PhotoponWrapper fromObject:photopon] getStatusForUser:item withBlock:^(NSString *status) {
        cell.detailTextLabel.text = status;
    }];

    
    
    
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

    
    return cell;
}


@end
