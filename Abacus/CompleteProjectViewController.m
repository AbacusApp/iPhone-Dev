//
//  CompleteProjectViewController.m
//  Abacus
//
//  Created by Graham Savage on 5/10/13.
//  Copyright (c) 2013 Graham Savage. All rights reserved.
//

#import "CompleteProjectViewController.h"
#import "UITextField+Customizations.h"
#import "UIViewController+Customizations.h"
#import "NSDate+Customizations.h"
#import "Alerts.h"

#define MAX_HOURS_LENGTH        4
#define MAX_EXPENSES_LENGTH     6

@interface CompleteProjectViewController ()
@property   (nonatomic, retain)     IBOutlet    UITextField     *hoursWorked, *additionalExpenses;
@property   (nonatomic, retain)     IBOutlet    UIScrollView    *scroller;
@property   (nonatomic, retain)     IBOutlet    UILabel         *name, *priceQuoted, *dates;
@property   (nonatomic, retain)                 UIView			*lastTextWidget;
- (IBAction)complete:(id)sender;
- (IBAction)close:(id)sender;

@end

@implementation CompleteProjectViewController
@synthesize hoursWorked, additionalExpenses, scroller, lastTextWidget, project, name, priceQuoted, dates;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.hoursWorked customize];
    [self.additionalExpenses customize];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardWillHideNotification object:nil];
    self.scroller.contentSize = self.scroller.bounds.size;
}

- (void)viewDidAppear:(BOOL)animated {
    Calculation *calculation = [Database calculationForGUID:project.calculationGUID];
    self.hoursWorked.text = [NSString stringWithFormat:@"%f.0f", calculation.hoursIn?calculation.hoursIn:calculation.hoursOut];
    [self formatBudgetField];
    [self formatHoursField];
}

- (void)setProject:(Project *)p {
    if (project) {
        [project release];
    }
    project = [p retain];
    self.name.text = project.name;
    Calculation *calculation = [Database calculationForGUID:project.calculationGUID];
    self.priceQuoted.text = [NSString stringWithFormat:@"Price quoted: $%.02f", calculation.quoteOut?calculation.quoteOut:calculation.budgetIn];
    self.dates.text = [NSString stringWithFormat:@"%@", [project.startingDate asDisplayString]];
}

- (void)dismissKeyboard {
    [self.lastTextWidget resignFirstResponder];
}

- (IBAction)close:(id)sender {
    [CompleteProjectViewController hideModally];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UNDO.PROJECT.COMPLETE" object:self.project];
}

- (IBAction)complete:(id)sender {
    [CompleteProjectViewController hideModally];
    self.project.status = ProjectStatusCompleted;
    
    Calculation *calculation = [Database calculationForGUID:project.calculationGUID];
    if ([hoursWorked.text intValue] <= calculation.hoursIn && [additionalExpenses.text doubleValue] <= calculation.operationsOut) {
        self.project.profitability = ProjectProfitabilityProfitable;
        [Alerts showWarningWithTitle:@"COMPLETE PROJECT" message:@"Congratulations!\nYour quote for this project was successful." delegate:self tag:1];
    } else {
        self.project.profitability = ProjectProfitabilityProfitable;
        if ([hoursWorked.text intValue] > calculation.hoursIn) {
            [Alerts showWarningWithTitle:@"COMPLETE PROJECT" message:@"You went over the amount of hours quoted. Visit the FAQ section for more information about how to estimate your hours for future reference." delegate:self tag:2];
        } else if ([additionalExpenses.text doubleValue] > calculation.operationsOut) {
            [Alerts showWarningWithTitle:@"COMPLETE PROJECT" message:@"Your additional expenses went over the quoted operations amount. Visit the FAQ section for more information about how establish your hourly rate to cover for operations expenses and how to deal with a situation in real time when you see that it won't be enough." delegate:self tag:3];
        } else if ([hoursWorked.text intValue] > calculation.hoursIn && [additionalExpenses.text doubleValue] > calculation.operationsOut) {
            [Alerts showWarningWithTitle:@"COMPLETE PROJECT" message:@"You went over the amount of hours quoted and your additional expenses went over the quoted operations amount. Visit the FAQ section for help and information on how to restructure your hourly prices to protect yourself and secure a profit in future projects." delegate:self tag:4];
        }
    }
    
    [Database updateProject:self.project];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PROJECT.COMPLETED" object:self.project];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

CGRect myFrame;
- (void)keyboardDidShow:(NSNotification *)note {
    myFrame = self.scroller.frame;
    // Resize the scroller view to sit against the top of the keyboard accessory ivew
    CGRect keyboardFrame  = [[note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect myFrameInWindowCoordinates = [self.view convertRect:self.scroller.frame toView:self.view.window];
    myFrameInWindowCoordinates = CGRectOffset(myFrameInWindowCoordinates, 0, self.scroller.contentOffset.y);
    CGFloat diff = CGRectGetMaxY(myFrameInWindowCoordinates) - keyboardFrame.origin.y;
    if (diff > 0) {
        self.scroller.contentSize = CGSizeMake(self.scroller.contentSize.width, self.scroller.contentSize.height + diff);
    }
}

- (void)keyboardDidHide:(NSNotification *)note {
    if (lastTextWidget) {
        [UIView animateWithDuration:.25 animations:^{
            self.scroller.contentSize = CGSizeMake(myFrame.size.width, myFrame.size.height);
        } completion:^(BOOL finished) {
            myFrame = CGRectZero;
        }];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.hoursWorked && textField.text.length) {
        textField.text = [textField.text substringWithRange:NSRangeFromString([NSString stringWithFormat:@"0 %d", textField.text.length-4])];
    }
    if (textField == self.additionalExpenses && textField.text.length) {
        textField.text = [textField.text substringWithRange:NSRangeFromString([NSString stringWithFormat:@"1 %d", textField.text.length-1])];
    }
	lastTextWidget = textField;
    CGFloat offset = lastTextWidget.frame.origin.y - lastTextWidget.frame.size.height;
    [self.scroller setContentOffset:CGPointMake(0, offset>0?offset:0) animated:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.hoursWorked) {
        [self formatHoursField];
    }
    if (textField == self.additionalExpenses) {
        [self formatBudgetField];
    }
}

- (void)formatHoursField {
    self.hoursWorked.text = [NSString stringWithFormat:@"%.0f hrs", [hoursWorked.text doubleValue]];
}

- (void)formatBudgetField {
    self.additionalExpenses.text = [NSString stringWithFormat:@"$%.0f", [additionalExpenses.text doubleValue]];
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == self.hoursWorked) {
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
    } else if (textField == self.additionalExpenses) {
        if ([string rangeOfCharacterFromSet:[NSCharacterSet alphanumericCharacterSet]].location == NSNotFound && !range.length) {
            return NO;
        }
        if ([textField.text length] == MAX_EXPENSES_LENGTH-1 && !range.length) {
            textField.text = [textField.text stringByAppendingString:string];
            return NO;
        }
        if ([textField.text length] > MAX_EXPENSES_LENGTH-1 && !range.length) {
            return NO;
        }
    }
    return YES;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [hoursWorked release];
    [additionalExpenses release];
    [scroller release];
    [lastTextWidget release];
    [project release];
    [name release];
    [priceQuoted release];
    [dates release];
    [super dealloc];
}
@end
