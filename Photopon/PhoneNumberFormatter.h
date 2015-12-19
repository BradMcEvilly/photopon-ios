

#import <Foundation/Foundation.h>



@interface PhoneNumberFormatter : NSObject


-(id)init;
-(NSString *)format:(NSString *)phoneNumber withLocale:(NSString *)locale;
-(NSString *)strip:(NSString *)phoneNumber;
-(BOOL)canBeInputByPhonePad:(char)c;

@end
