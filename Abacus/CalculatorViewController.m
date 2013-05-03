//
//  CalculatorViewController.m
//  Abacus
//
//  Created by Graham Savage on 5/3/13.
//  Copyright (c) 2013 Graham Savage. All rights reserved.
//

#import "CalculatorViewController.h"
#import "UITextField+Customizations.h"

@interface CalculatorViewController ()
@property   (nonatomic, retain)     IBOutlet    UITextField     *hours, *budget;
@end

@implementation CalculatorViewController
@synthesize hours, budget;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.hours customize];
    [self.budget customize];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)dealloc {
    [hours release];
    [budget release];
    [super dealloc];
}
@end
