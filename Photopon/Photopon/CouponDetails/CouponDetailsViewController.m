//
//  CouponDetailsViewController.m
//  Photopon
//
//  Created by Ante Karin on 01/10/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import "CouponDetailsViewController.h"
#import <MapKit/MapKit.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <Parse/PFGeoPoint.h>
#import "CouponLocationAnnotation.h"
#import "CouponWrapper.h"
#import "Helper.h"
#import "UIColor+Convinience.h"
#import "RoundedBorderedView.h"

@interface CouponDetailsViewController() <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (weak, nonatomic) IBOutlet UILabel *couponTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *couponExpirationLabel;
@property (weak, nonatomic) IBOutlet UILabel *couponSubtitleLabel;

@property (weak, nonatomic) IBOutlet UIImageView *couponImageView;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet RoundedBorderedView *detailsContainer;

@end

@implementation CouponDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (void)setupUI {
    self.title = @"Gift details";

    self.couponTitleLabel.text = [self.coupon objectForKey:@"title"];
    self.couponSubtitleLabel.text = [self.coupon objectForKey:@"desc"];

    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:@"MM/dd/yyyy"];
    NSDate *exp  = [self.coupon objectForKey:@"expiration"];
    self.couponExpirationLabel.text = [NSString stringWithFormat:@"Expires %@", [dateFormater stringFromDate:exp]];
    [self.couponImageView sd_setImageWithURL:[NSURL URLWithString:[self.coupon objectForKey:@"pic"]] placeholderImage:[UIImage imageNamed:@"couponplaceholder.png"]];

    NSArray *locations = [self.coupon objectForKey:@"locations"];
    NSNumber *locationID = locations.firstObject;

    PFQuery *query = [PFQuery queryWithClassName:@"Location" predicate:[NSPredicate predicateWithFormat:@"objectId == %@", locationID]];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        PFObject *location = objects.firstObject;
        if (location) {
            self.addressLabel.text = location[@"address"];
            PFGeoPoint *point = location[@"location"];
            CouponLocationAnnotation *annotation = [[CouponLocationAnnotation alloc]init];
            annotation.coordinate = CLLocationCoordinate2DMake(point.latitude, point.longitude);
            annotation.title = self.coupon[@"title"];
            [self.mapView addAnnotation:annotation];
            MKCoordinateRegion region = MKCoordinateRegionMake(annotation.coordinate, MKCoordinateSpanMake(0.002, 0.002));
            [self.mapView setRegion:region];
        }
    }];

    self.mapView.layoutMargins = UIEdgeInsetsMake(0, 0, 20, 0);
    self.detailsContainer.corners = UIRectCornerTopLeft | UIRectCornerTopRight;
    self.detailsContainer.borderColor = [UIColor colorWithHexString:@"#COCOCO" alpha:0.3];
}


- (IBAction)getCouponButtonHandler:(id)sender {
    [self getCoupon];
}

- (IBAction)giveCouponButtonHandler:(id)sender {
    [self giveCoupon];
}

- (IBAction)locateButtonHandler:(id)sender {
    [self.mapView setCenterCoordinate:GetLocationManager().location.coordinate animated:YES];
}

-(void)getCoupon {
    CouponWrapper* wrapper = [CouponWrapper fromObject:self.coupon];
    [wrapper getCoupon];
}

-(void)giveCoupon {

    [[NSNotificationCenter defaultCenter] postNotificationName:@"Goto_AddPhotopon" object:nil userInfo:@{
                                                                                                         @"index": @(self.selectedCouponIndex)
                                                                                                         }];
    [self dismissViewControllerAnimated:YES completion:nil];

    SendGAEvent(@"user_action", @"coupon_details", @"give_pressed");
}

#pragma mark - Map view delegate

- (nullable MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }

    MKAnnotationView *annotationView = [[MKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"CouponLocations"];
    annotationView.frame = CGRectMake(0, 0, 60, 74);

    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"coupon-pin"]];
    [annotationView addSubview:imageView];
    annotationView.centerOffset = CGPointMake(0, -annotationView.frame.size.height / 2);
    return  annotationView;
}

@end
