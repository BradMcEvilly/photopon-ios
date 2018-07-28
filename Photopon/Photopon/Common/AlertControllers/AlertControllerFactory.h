//
//  AlertControllerFactory.h
//
//  Created by Ante Karin on 27/05/16.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AlertControllerFactory : NSObject

+ (UIAlertController *)singleDismissActionAlertWithAlertTitle:(NSString *)title message:(NSString *)message actionTitle:(NSString *)title;
+ (UIAlertController *)basicAlertWithMessage:(NSString *)message;
+ (UIAlertController *)basicAlertWithMessage:(NSString *)message completion:(void (^)(void))completion;
+ (UIAlertController *)basicConfirmWithMessage:(NSString *)message completion:(void (^)(void))completion;


@end
