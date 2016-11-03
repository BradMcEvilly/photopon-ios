//
//  SentPhotopons.m
//  Photopon
//
//  Created by Hayk Hayotsyan on 25/7/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import "SentPhotopons.h"
#import "SentPhotoponDetail.h"
#import "HeaderViewController.h"
#import "DBAccess.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "PhotoponWrapper.h"

@implementation SentPhotopons

{
    NSMutableArray *sentPhotoponList;
    NSMutableArray* resolvedData;
}


-(void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [HeaderViewController addBackHeaderToView:self withTitle:@"Sent"];
    
    
    [self.sentPhotopons setDelegate:self];
    [self.sentPhotopons setDataSource:self];

    
    GetSentPhotopons(^(NSArray *results, NSError *error) {
        sentPhotoponList = [NSMutableArray arrayWithArray:results];
        
        resolvedData = [NSMutableArray arrayWithCapacity:[results count]];
        
        for (int i = 0; i < [results count]; ++i) {
            resolvedData[i] = [NSString new];
        }
        [self.sentPhotopons reloadData];
    });
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnTableView:)];
    [self.sentPhotopons addGestureRecognizer:tap];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [sentPhotoponList count];
}


- (void)didTapOnTableView:(UIGestureRecognizer*) recognizer {
    CGPoint tapLocation = [recognizer locationInView:self.sentPhotopons];
    NSIndexPath *indexPath = [self.sentPhotopons indexPathForRowAtPoint:tapLocation];
    
    if (!indexPath) {
        return;
    }
    
    PFObject *item = [sentPhotoponList objectAtIndex:indexPath.row];

    
    
    SentPhotoponDetail* details = [self.storyboard instantiateViewControllerWithIdentifier:@"SBSentDetail"];
    [details setPhotopon: item];
    
    [self presentViewController:details animated:YES completion:nil];

}






- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SentPhotoponsList"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"SentPhotoponsList"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    PFObject *item = [sentPhotoponList objectAtIndex:indexPath.row];
    
    PFObject* coupon = [item objectForKey:@"coupon"];
    PFObject* company = [coupon objectForKey:@"company"];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", [company objectForKey:@"name"], [coupon objectForKey:@"title"]];
    
    NSDate *updated = [item updatedAt];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMM d, h:mm a"];
    int numFriends = (int)[[item objectForKey:@"users"] count];
    
    
    
    if (![resolvedData[indexPath.row] isEqualToString:@""]) {
        
        cell.detailTextLabel.text = resolvedData[indexPath.row];
        
    } else {
        
        if (numFriends == 1) {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"Sent at %@ to 1 friend", [dateFormat stringFromDate:updated]];
        } else {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"Sent at %@ to %i friends", [dateFormat stringFromDate:updated], numFriends];
        }
        
        [[PhotoponWrapper fromObject:item] grabUsers:^(NSArray *results) {
            NSString* usersText = @"";
            
            int c = MIN(3, (int)[results count]);
            
            for (int i = 0; i < c; ++i) {
                if ([results[i] isKindOfClass:[PFUser class]]) {
                    if (results[i][@"phone"]) {
                        usersText = [usersText stringByAppendingString:results[i][@"phone"]];
                    }
                } else {
                    if ([results[i] username]) {
                        usersText = [usersText stringByAppendingString:[results[i] username]];
                    }
                }
                if (i != c - 1) {
                    usersText = [usersText stringByAppendingString:@", "];
                }
            }
            
            if ([results count] > 3) {
                usersText = [usersText stringByAppendingString:@" and more"];
            }
            
            cell.detailTextLabel.text = [NSString stringWithFormat:@"Sent at %@ to %@", [dateFormat stringFromDate:updated], usersText];
            resolvedData[indexPath.row] = [cell.detailTextLabel.text copy];
            NSLog(@"Set %@ at %li", cell.detailTextLabel.text, (long)indexPath.row);
            
        }];
    }
    
    
    cell.imageView.image = [UIImage imageNamed:@"Icon-Present.png"];
    PFFile* imgObj = [company objectForKey:@"image"];
    NSString* img = imgObj.url;
    
    if (img) {
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:img] placeholderImage:[UIImage imageNamed:@"Icon-Present.png"]  options:SDWebImageAvoidAutoSetImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [cell.imageView setImage:image];
                
                cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
                
            });
            
        }];
    } else {
        [cell.imageView setImage:[UIImage imageNamed:@"Icon-Present.png"]];
        
    }
    

    
    return cell;
}



@end
