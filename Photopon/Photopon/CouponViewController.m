//
//  CouponViewController.m
//  Photopon
//
//  Created by Hayk Hayotsyan on 21/8/15.
//  Copyright (c) 2015 Photopon. All rights reserved.
//

#import "CouponViewController.h"
#import "PhotoponViewController.h"
#import "Parse/Parse.h"
#import "LogHelper.h"
#import "DBAccess.h"
#import <SDWebImage/UIImageView+WebCache.h>


@implementation CouponViewController
{
    NSMutableArray* allCoupons;
}


-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.couponTable setDelegate:self];
    [self.couponTable setDataSource:self];
    allCoupons = [NSMutableArray array];
    
    
    GetCoupons(^(NSArray *results, NSError *error) {
        for (PFObject* object in results) {
            
            NSString* title = [object objectForKey:@"title"];
            NSString* desc = [object objectForKey:@"description"];
            PFObject* company = [object objectForKey:@"company"];
            [company fetchIfNeeded];
            PFFile* pic = [company objectForKey:@"image"];
            
            [allCoupons addObject:@{
               @"title": title,
               @"desc": desc,
               @"pic": pic.url
            }];
        }
        [self.couponTable reloadData];
    });

}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [allCoupons count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MyIdentifier"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSDictionary *item = (NSDictionary *)[allCoupons objectAtIndex:indexPath.row];
    cell.textLabel.text = [item objectForKey:@"title"];
    cell.detailTextLabel.text = [item objectForKey:@"desc"];
    
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:[item objectForKey:@"pic"]] placeholderImage:[UIImage imageNamed:@"couponplaceholder.png"]];

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%ld", indexPath.row);
    
    PhotoponViewController* photoponCtrl = (PhotoponViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"SBPhotopon"];
    [photoponCtrl setCoupon:[allCoupons objectAtIndex:indexPath.row]];
    
    [self.navigationController pushViewController:photoponCtrl animated:true];

}


@end
