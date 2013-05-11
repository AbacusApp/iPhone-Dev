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
@synthesize hoursWorked, additionalExpenses, scroller, lastTextWidget, project, name, priceQuoted, dates, calculation;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.hoursWorked customize];
    [self.additionalExpenses customize];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardWillHideNotification object:nil];
    self.scroller.contentSize = self.scroller.bounds.size;
}

- (void)viewDidAppear:(BOOL)animated {
    self.hoursWorked.text = [NSString stringWithFormat:@"%f.0f", self.project.hoursTaken];
    [self formatBudgetField];
    [self formatHoursField];
}

- (void)setProject:(Project *)p {
    if (project) {
        [project release];
    }
    project = [p retain];
    self.name.text = project.name;
    self.priceQuoted.text = [NSString stringWithFormat:@"Price quoted: $%.02f", project.initialQuote];
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
    [Database updateProject:self.project];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PROJECT.COMPLETED" object:self.project];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.hoursWorked) {
        [self.additionalExpenses becomeFirstResponder];
    } else if (textField == additionalExpenses) {
        [additionalExpenses resignFirstResponder];
    }
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
    [calculation release];
    [super dealloc];
}
@end
