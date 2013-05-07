//
//  CalculatorViewController.m
//  Abacus
//
//  Created by Graham Savage on 5/3/13.
//  Copyright (c) 2013 Graham Savage. All rights reserved.
//

#import "CalculatorViewController.h"
#import "UITextField+Customizations.h"
#import "Persist.h"
#import "Alerts.h"

#define MAX_HOURS_LENGTH        4
#define MAX_BUDGET_LENGTH       6

@interface CalculatorViewController ()
@property   (nonatomic, retain)     IBOutlet    UITextField     *hours, *budget;
@property   (nonatomic, retain)     IBOutlet    UIScrollView    *scroller;
@property   (nonatomic, retain)     IBOutlet    UILabel         *resultCompany1, *resultOperations1, *resultSalary1, *resultQuote;
@property   (nonatomic, retain)     IBOutlet    UILabel         *resultCompany2, *resultOperations2, *resultSalary2, *resultWork;

- (IBAction)tabTapped:(UIButton *)sender;
- (IBAction)calculate:(UIButton *)sender;
@end

@implementation CalculatorViewController
@synthesize hours, budget, scroller, resultCompany1, resultOperations1, resultSalary1, resultCompany2, resultOperations2, resultSalary2, resultWork, resultQuote;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.hours customize];
    [self.budget customize];
    self.scroller.contentSize = CGSizeMake(self.scroller.frame.size.width*2, self.scroller.frame.size.height);
    /*
    UILabel *hrs = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 44, 44)] autorelease];
    hrs.text = @"hrs";
    hrs.backgroundColor = [UIColor clearColor];
    hrs.textColor = self.hours.textColor;
    hrs.font = self.hours.font;
    self.hours.rightView = hrs;
    self.hours.rightViewMode = UITextFieldViewModeAlways;
     */
}

- (IBAction)tabTapped:(UIButton *)sender {
    [self.scroller setContentOffset:CGPointMake(sender.tag * self.scroller.frame.size.width, 0) animated:YES];
    [self.hours resignFirstResponder];
    [self.budget resignFirstResponder];
}

- (IBAction)calculate:(UIButton *)sender {
    double hoursSpecified = [hours.text doubleValue];
    double budgetSpecified = [budget.text doubleValue];
    double rate = [[Persist valueFor:@"HOURLY.RATE" secure:NO] doubleValue];
    switch (sender.tag) {
        case 0:     // by amount of hours
            if (hoursSpecified == 0) {
                [Alerts showWarningWithTitle:@"Hours" message:@"Please enter the number of hours required" delegate:self];
                return;
            }
            resultCompany1.text = [NSString stringWithFormat:@"$%.02f", hoursSpecified * rate / 4.0];
            resultOperations1.text = [NSString stringWithFormat:@"$%.02f", hoursSpecified * rate / 4.0];
            resultSalary1.text = [NSString stringWithFormat:@"$%.02f", hoursSpecified * rate / 2.0];
            resultQuote.text = [NSString stringWithFormat:@"$%.02f", hoursSpecified * rate];
            break;
        case 1:     // by client budget
            if (budgetSpecified <= 1.0) {
                [Alerts showWarningWithTitle:@"Budget" message:@"Please enter the client's budget" delegate:self];
                return;
            }
            resultCompany2.text = [NSString stringWithFormat:@"$%.02f", budgetSpecified / 4.0];
            resultOperations2.text = [NSString stringWithFormat:@"$%.02f", budgetSpecified / 4.0];
            resultSalary2.text = [NSString stringWithFormat:@"$%.02f", budgetSpecified / 2.0];
            resultWork.text = [NSString stringWithFormat:@"%.0f hrs", budgetSpecified/rate];
            break;
    }
    [self.hours resignFirstResponder];
    [self.budget resignFirstResponder];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == self.hours) {
        if ([string rangeOfCharacterFromSet:[NSCharacterSet alphanumericCharacterSet]].location == NSNotFound && !range.length) {
            return NO;
        }
        if ([textField.text length] == MAX_HOURS_LENGTH-1 && !range.length) {
            textField.text = [textField.text stringByAppendingString:string];
            return NO;
        }
        if ([textField.text length] > MAX_HOURS_LENGTH-1 && !range.length) {
            return NO;
        }
    } else if (textField == self.budget) {
        if ([string rangeOfCharacterFromSet:[NSCharacterSet alphanumericCharacterSet]].location == NSNotFound && !range.length) {
            return NO;
        }
        if ([textField.text length] == MAX_BUDGET_LENGTH-1 && !range.length) {
            textField.text = [textField.text stringByAppendingString:string];
            return NO;
        }
        if ([textField.text length] > MAX_BUDGET_LENGTH-1 && !range.length) {
            return NO;
        }
    }
    return YES;
}

- (void)dealloc {
    [hours release];
    [budget release];
    [scroller release];
    [resultCompany1 release];
    [resultOperations1 release];
    [resultSalary1 release];
    [resultCompany2 release];
    [resultOperations2 release];
    [resultSalary2 release];
    [resultWork release];
    [resultQuote release];
    [super dealloc];
}
@end
