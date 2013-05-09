//
//  CalculatorViewController.m
//  Abacus
//
//  Created by Graham Savage on 5/3/13.
//  Copyright (c) 2013 Graham Savage. All rights reserved.
//


#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>
#import "UITextField+Customizations.h"

@implementation UITextField (Customizations)

- (void)customize {
    UIView *padding = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 6, self.frame.size.height)] autorelease];
    self.leftViewMode = UITextFieldViewModeAlways;
    self.leftView = padding;
    self.background = [UIImage imageNamed:@"text.field.background.png"];
}

@end
