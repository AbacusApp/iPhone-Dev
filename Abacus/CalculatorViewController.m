//
//  CalculatorViewController.m
//  Abacus
//
//  Created by Graham Savage on 5/3/13.
//  Copyright (c) 2013 Graham Savage. All rights reserved.
//

#import "CalculatorViewController.h"
#import "UITextField+Customizations.h"
#import "Alerts.h"
#import "Database.h"
#import "Persist.h"
#import "EditProjectViewController.h"
#import "UIViewController+Customizations.h"
#import "RadioButton.h"

#define MAX_HOURS_LENGTH        4
#define MAX_BUDGET_LENGTH       6

@interface CalculatorViewController ()
@property   (nonatomic, retain)     IBOutlet    UITextField     *hours, *budget;
@property   (nonatomic, retain)     IBOutlet    UIScrollView    *scroller;
@property   (nonatomic, retain)     IBOutlet    UILabel         *resultCompany1, *resultOperations1, *resultSalary1, *resultQuote;
@property   (nonatomic, retain)     IBOutlet    UILabel         *resultCompany2, *resultOperations2, *resultSalary2, *resultWork;
@property   (nonatomic, retain)     IBOutlet    UIButton        *calculateButtonHours, *calculateButtonBudget;
@property   (nonatomic, retain)     IBOutlet    UIView          *resultsContainer;
@property   (nonatomic, retain)     IBOutlet    RadioButton     *hoursRadio, *budgetRadio;
@property   (nonatomic, retain)     IBOutlet    UILabel         *purpleUnderbelly;

- (IBAction)tabTapped:(UIButton *)sender;
- (IBAction)revealMenu:(id)sender;
- (IBAction)calculate:(UIButton *)sender;
@end

@implementation CalculatorViewController
@synthesize hours, budget, scroller, resultCompany1, resultOperations1, resultSalary1, resultCompany2, resultOperations2, resultSalary2, resultWork, resultQuote;
@synthesize calculateButtonBudget, calculateButtonHours, resultsContainer, hoursRadio, budgetRadio, purpleUnderbelly;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.hours customize];
    [self.budget customize];
    self.scroller.contentSize = CGSizeMake(self.scroller.frame.size.width*2, self.scroller.frame.size.height);
    NSString *savedHours = [Persist valueFor:@"calculator.hours" secure:NO];
    if (savedHours) {
        self.hours.text = savedHours;
        [self formatHoursField];
        [self calculate:self.calculateButtonHours];
    }
    NSString *savedBudget = [Persist valueFor:@"calculator.budget" secure:NO];
    if (savedBudget) {
        self.budget.text = savedBudget;
        [self formatBudgetField];
        [self calculate:self.calculateButtonBudget];
    }
    UISwipeGestureRecognizer *right = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe)] autorelease];
    right.direction = UISwipeGestureRecognizerDirectionRight;
    [self.resultsContainer addGestureRecognizer:right];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(projectCreated) name:@"PROJECT.CREATED" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(undoProjectCreate) name:@"UNDO.PROJECT.EDIT" object:nil];
}

- (void)smallReveal {
    [UIView animateWithDuration:.20 delay:.20 options:0 animations:^{
        resultsContainer.frame = CGRectMake(10, resultsContainer.frame.origin.y, resultsContainer.frame.size.width, resultsContainer.frame.size.height);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.20 animations:^{
            resultsContainer.frame = CGRectMake(0, resultsContainer.frame.origin.y, resultsContainer.frame.size.width, resultsContainer.frame.size.height);
        }];
    }];
}

- (void)projectCreated {
    [UIView animateWithDuration:.20 animations:^{
        resultsContainer.frame = CGRectMake(0, resultsContainer.frame.origin.y, resultsContainer.frame.size.width, resultsContainer.frame.size.height);
    } completion:^(BOOL finished) {
    }];
}

- (void)undoProjectCreate {
    [UIView animateWithDuration:.20 animations:^{
        resultsContainer.frame = CGRectMake(0, resultsContainer.frame.origin.y, resultsContainer.frame.size.width, resultsContainer.frame.size.height);
    } completion:^(BOOL finished) {
    }];
}

// ┌────────────────────────────────────────────────────────────────────────────────────────────────────
// │ User swipes to create a project
// └────────────────────────────────────────────────────────────────────────────────────────────────────
- (void)swipe {
    double qte = [[resultQuote.text stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"$"]] doubleValue];
    double hrs = [[resultWork.text stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" hrs"]] doubleValue];
    if (hoursRadio.selected) {
        if (qte == 0) {
            return;     // If the user has not yet done a calculation then do nothing
        }
    } else if (hrs == 0){
        return;         // If the user has not yet done a calculation then do nothing
    }
    
    [UIView animateWithDuration:.35 animations:^{
        resultsContainer.frame = CGRectMake(resultsContainer.frame.size.width, resultsContainer.frame.origin.y, resultsContainer.frame.size.width, resultsContainer.frame.size.height);
    } completion:^(BOOL finished) {
        [self editProject];
    }];
}

- (void)editProject {
    double qte = [[resultQuote.text stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"$"]] doubleValue];
    double hrs = [[resultWork.text stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" hrs"]] doubleValue];
    EditProjectViewController *ep = [EditProjectViewController showModally];
    ep.project = [[[Project alloc] init] autorelease];
    Calculation *calculation = [[[Calculation alloc] init] autorelease];
    calculation.hourlyRate = [Database profile].hourlyRate;
    ep.project.calculationGUID = calculation.guid;
    ep.calculation = calculation;
    if (hoursRadio.selected) {
        calculation.type = CalculationTypeByHours;
        calculation.hoursIn = [[hours.text stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" hrs"]] doubleValue];
        calculation.companyOut = [[resultCompany1.text stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"$"]] doubleValue];
        calculation.operationsOut = [[resultOperations1.text stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"$"]] doubleValue];
        calculation.salaryOut = [[resultSalary1.text stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"$"]] doubleValue];
        calculation.quoteOut = qte;
    } else {
        calculation.type = CalculationTypeByBudget;
        calculation.budgetIn = [[budget.text stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"$"]] doubleValue];
        calculation.companyOut = [[resultCompany2.text stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"$"]] doubleValue];
        calculation.operationsOut = [[resultOperations2.text stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"$"]] doubleValue];
        calculation.salaryOut = [[resultSalary2.text stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"$"]] doubleValue];
        calculation.hoursOut = hrs;
    }
}

- (void)formatHoursField {
    self.hours.text = [NSString stringWithFormat:@"%.0f hrs", [hours.text doubleValue]];
}

- (void)formatBudgetField {
    self.budget.text = [NSString stringWithFormat:@"$%.0f", [budget.text doubleValue]];
}

- (IBAction)tabTapped:(UIButton *)sender {
    [self.scroller setContentOffset:CGPointMake((sender.tag-1) * self.scroller.frame.size.width, 0) animated:YES];
    [self.hours resignFirstResponder];
    [self.budget resignFirstResponder];
}

- (IBAction)calculate:(UIButton *)sender {
    [self.hours resignFirstResponder];
    [self.budget resignFirstResponder];
    double rate = [Database profile].hourlyRate;
    switch (sender.tag) {
        case 0: {    // by amount of hours
            double hoursSpecified = [hours.text doubleValue];
            if (hoursSpecified == 0) {
                [Alerts showWarningWithTitle:@"Hours" message:@"Please enter the number of hours required" delegate:self];
                [self.hours becomeFirstResponder];
                return;
            }
            resultCompany1.text = [NSString stringWithFormat:@"$%.02f", hoursSpecified * rate / 4.0];
            resultOperations1.text = [NSString stringWithFormat:@"$%.02f", hoursSpecified * rate / 4.0];
            resultSalary1.text = [NSString stringWithFormat:@"$%.02f", hoursSpecified * rate / 2.0];
            resultQuote.text = [NSString stringWithFormat:@"$%.02f", hoursSpecified * rate];
        }
            break;
        case 1: {    // by client budget
            double budgetSpecified = [[budget.text stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"$"]] doubleValue];
            if (budgetSpecified <= 1.0) {
                [Alerts showWarningWithTitle:@"Budget" message:@"Please enter the client's budget" delegate:self];
                [self.budget becomeFirstResponder];
                return;
            }
            resultCompany2.text = [NSString stringWithFormat:@"$%.02f", budgetSpecified / 4.0];
            resultOperations2.text = [NSString stringWithFormat:@"$%.02f", budgetSpecified / 4.0];
            resultSalary2.text = [NSString stringWithFormat:@"$%.02f", budgetSpecified / 2.0];
            resultWork.text = [NSString stringWithFormat:@"%.0f hrs", budgetSpecified/rate];
        }
            break;
    }
    [self smallReveal];
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

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.hours && textField.text.length) {
        textField.text = [textField.text substringWithRange:NSRangeFromString([NSString stringWithFormat:@"0 %d", textField.text.length-4])];
    }
    if (textField == self.budget && textField.text.length) {
        textField.text = [textField.text substringWithRange:NSRangeFromString([NSString stringWithFormat:@"1 %d", textField.text.length-1])];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.hours) {
        [Persist setValue:textField.text forKey:@"calculator.hours" secure:NO];
        [self formatHoursField];
    }
    if (textField == self.budget) {
        [Persist setValue:budget.text forKey:@"calculator.budget" secure:NO];
        [self formatBudgetField];
    }
}

- (IBAction)revealMenu:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"REVEAL.MENU" object:nil];
}

- (void)dealloc {
    [purpleUnderbelly release];
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
    [calculateButtonHours release];
    [calculateButtonBudget release];
    [resultsContainer release];
    [hoursRadio release];
    [budgetRadio release];
    [super dealloc];
}
@end

