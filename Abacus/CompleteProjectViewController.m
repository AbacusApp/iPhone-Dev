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
}

- (IBAction)complete:(id)sender {
    [CompleteProjectViewController hideModally];
    self.project.status = ProjectStatusCompleted;
    [Database updateProject:self.project];
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
	lastTextWidget = textField;
    CGFloat offset = lastTextWidget.frame.origin.y - lastTextWidget.frame.size.height;
    [self.scroller setContentOffset:CGPointMake(0, offset>0?offset:0) animated:YES];
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
