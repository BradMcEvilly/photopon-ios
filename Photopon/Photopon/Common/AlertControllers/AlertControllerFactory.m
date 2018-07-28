//
//  AlertControllerFactory.m
//
//  Created by Ante Karin on 27/05/16.
//

#import "AlertControllerFactory.h"

@implementation AlertControllerFactory

+ (UIAlertController *)singleDismissActionAlertWithAlertTitle:(NSString *)title message:(NSString *)message actionTitle:(NSString *)actionTitle {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:actionTitle style:UIAlertActionStyleDefault handler:nil]];
    return alertController;
}

+ (UIAlertController *)basicAlertWithMessage:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Photopon" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    return alertController;
}

+ (UIAlertController *)basicAlertWithMessage:(NSString *)message completion:(void (^)(void))completion {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Photopon" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (completion) {
            completion();
        }
    }]];
    return alertController;
}

+ (UIAlertController *)basicConfirmWithMessage:(NSString *)message completion:(void (^)(void))completion {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Photopon" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (completion) {
            completion();
        }
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
      
    }]];
    return alertController;
}

@end
