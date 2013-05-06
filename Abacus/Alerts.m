//
//  Abacus
//
//  Created by Graham Savage on 5/3/13.
//  Copyright (c) 2013 Graham Savage. All rights reserved.
//

#import "Alerts.h"

@implementation Alerts
UIAlertView *alert = nil;    
UIAlertView *busy = nil;    

+ (void)showQuestionWithTitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel ok:(NSString *)ok delegate:(id)delegate tag:(int)tag {
    alert = [[[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancel otherButtonTitles:ok,nil] autorelease];
    alert.delegate = delegate;
    alert.tag = tag;
    [alert show]; 
}

+ (void)showQuestionWithTitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel ok:(NSString *)ok delegate:(id)delegate {
    [self showQuestionWithTitle:title message:message cancel:cancel ok:ok delegate:delegate tag:0];
}

+ (void)showWarningWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate {
    NSArray *params = [NSArray arrayWithObjects:title, message, delegate, [NSNumber numberWithInt:0], nil];
    [self performSelectorOnMainThread:@selector(_showWarning:) withObject:params waitUntilDone:NO];
}

+ (void)showWarningWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate tag:(int)tag {
    NSArray *params = [NSArray arrayWithObjects:title, message, delegate, [NSNumber numberWithInt:tag], nil];
    [self performSelectorOnMainThread:@selector(_showWarning:) withObject:params waitUntilDone:NO];
}

+ (void)_showWarning:(NSArray *)params {
    NSString *title = [params objectAtIndex:0];
    NSString *message = [params objectAtIndex:1];
    id delegate = [params objectAtIndex:2];
    int tag = [[params objectAtIndex:3] intValue];
    alert = [[[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
    alert.tag = tag;
    alert.delegate = delegate;
    [alert show];
}

+ (void)showError:(NSError *)error forDelegate:(id)delegate {
    NSArray *params = [NSArray arrayWithObjects:error, delegate, nil];
    [self performSelectorOnMainThread:@selector(_showError:) withObject:params waitUntilDone:NO];
}

+ (void)_showError:(NSArray *)params {
    NSError *error = [params objectAtIndex:0];
    id delegate = [params objectAtIndex:1];
    [self showWarningWithTitle:error.domain message:error.localizedDescription delegate:delegate];    
}

+ (void)showBusyWithTitle:(NSString *)title message:(NSString *)message {
    NSArray *params = [NSArray arrayWithObjects:title, message, nil];
    [self performSelectorOnMainThread:@selector(_showBusy:) withObject:params waitUntilDone:NO];
}

+ (void)_showBusy:(NSArray *)params {
    NSString *title = [params objectAtIndex:0];
    NSString *message = [params objectAtIndex:1];
    busy = [[[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:nil] autorelease];
    [busy show];
    UIActivityIndicatorView *spinner = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
    spinner.frame = CGRectMake(busy.frame.size.width/2 - 35, busy.frame.size.height/2 + 8, 37, 37);
    [spinner startAnimating];
    [busy addSubview:spinner];
}

+ (void)hideBusy {
    [self performSelectorOnMainThread:@selector(_hide) withObject:nil waitUntilDone:NO];
}

+ (void)_hide {
    [busy dismissWithClickedButtonIndex:0 animated:YES];
    busy = nil;
}

@end