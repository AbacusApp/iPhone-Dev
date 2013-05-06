//
//  Abacus
//
//  Created by Graham Savage on 5/3/13.
//  Copyright (c) 2013 Graham Savage. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Alerts : NSObject {
}
+ (void)showQuestionWithTitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel ok:(NSString *)ok delegate:(id)delegate tag:(int)tag;
+ (void)showQuestionWithTitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel ok:(NSString *)ok delegate:(id)delegate;
+ (void)showWarningWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate;
+ (void)showWarningWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate tag:(int)tag;
+ (void)showError:(NSError *)error forDelegate:(id)delegate;
+ (void)showBusyWithTitle:(NSString *)title message:(NSString *)message;
+ (void)hideBusy;
@end