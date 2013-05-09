//
//  UIViewController+Customizations.m
//  Abacus
//
//  Created by Graham Savage on 5/9/13.
//  Copyright (c) 2013 Graham Savage. All rights reserved.
//

#import "UIViewController+Customizations.h"
#import "AppDelegate.h"

static  UIViewController   *instance = nil;

@implementation UIViewController (Customizations)

// ┌────────────────────────────────────────────────────────────────────────────────────────────────────
// │ Custom view display method
// └────────────────────────────────────────────────────────────────────────────────────────────────────
+ (void)showModally {
    NSString *className = NSStringFromClass(self.class);
    instance = [[self.class alloc] initWithNibName:className bundle:nil];
    UIWindow *window = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).window;
    [window addSubview:instance.view];
    instance.view.frame = window.bounds;
    instance.view.alpha = 0;
    [UIView animateWithDuration:.25 animations:^{
        instance.view.alpha = 1;
    } completion:^(BOOL finished) {
    }];
}

// ┌────────────────────────────────────────────────────────────────────────────────────────────────────
// │ Custom view hide method
// └────────────────────────────────────────────────────────────────────────────────────────────────────
+ (void)hideModally {
    [UIView animateWithDuration:.25 animations:^{
        instance.view.alpha = 0;
    } completion:^(BOOL finished) {
        [instance.view removeFromSuperview];
        [instance release];
        instance = nil;
    }];
}

@end
