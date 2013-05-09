//
//  EditProjectViewController.m
//  Abacus
//
//  Created by Graham Savage on 5/8/13.
//  Copyright (c) 2013 Graham Savage. All rights reserved.
//

#import "EditProjectViewController.h"
#import "AppDelegate.h"
#import "UITextField+Customizations.h"
#import "UIViewController+Customizations.h"
#import "UITextView+Customizations.h"

@interface EditProjectViewController ()
@property   (nonatomic, retain)     IBOutlet    UITextField     *name, *startDate;
@property   (nonatomic, retain)     IBOutlet    UITextView      *description;
@property   (nonatomic, retain)     IBOutlet    UIScrollView    *scroller;
@property   (nonatomic, retain)                 UIView			*lastTextWidget;
@property   (nonatomic, retain)     IBOutlet    UIButton        *closeButton, *createButton;

- (IBAction)close:(id)sender;
@end

@implementation EditProjectViewController
@synthesize name, startDate, description, scroller, lastTextWidget, closeButton, createButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.name customize];
    [self.startDate customize];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardWillHideNotification object:nil];
    self.scroller.contentSize = self.scroller.bounds.size;
    [self.description setPlaceholder:@"Project description"];
    self.scroller.contentSize = self.scroller.bounds.size;
}

- (IBAction)close:(id)sender {
    [EditProjectViewController hideModally];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.name) {
        [description becomeFirstResponder];
    } else if (textField == startDate) {
        [startDate resignFirstResponder];
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

- (void)textViewDidBeginEditing:(UITextView *)textField {
	lastTextWidget = textField;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [startDate becomeFirstResponder];
        return NO;
    }
    return YES;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [name release];
    [startDate release];
    [description release];
    [scroller release];
    [lastTextWidget release];
    [closeButton release];
    [createButton release];
    [super dealloc];
}
@end
