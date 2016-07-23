//
//  GoogleMapsManager.m
//  Photopon
//
//  Created by Ante Karin on 22/07/16.
//  Copyright © 2016 Photopon. All rights reserved.
//

#import "GoogleMapsManager.h"
#import "URLConstants.h"

static NSString * const GoogleMapsURLFormat = @"//?&daddr=%@&directionsmode=transit";
static NSString * const GoogleMapsWebURLFormat = @"https://maps.google.com/?daddr=%@";

@implementation GoogleMapsManager

+ (void)performNavigateToAddress:(NSString *)address {
    if ((address.length > 0)) {
        if ([[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:GoogleMapsURLScheme]]) {
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:GoogleMapsURLFormat, [address stringByReplacingOccurrencesOfString:@" " withString:@"+"]]];
            [[UIApplication sharedApplication]openURL:url];
        } else {
            NSURL *webMapsURL = [NSURL URLWithString:[NSString stringWithFormat:GoogleMapsWebURLFormat, [address stringByReplacingOccurrencesOfString:@" " withString:@"+"]]];
            [[UIApplication sharedApplication]openURL:webMapsURL];
        }
    }
}

@end
