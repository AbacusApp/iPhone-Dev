//
//  CalculatorViewController.m
//  Abacus
//
//  Created by Graham Savage on 5/3/13.
//  Copyright (c) 2013 Graham Savage. All rights reserved.
//


#import "PullDown.h"
#import <QuartzCore/QuartzCore.h>

@interface PullDown () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property   (nonatomic, retain)     UITableView     *table;
@property   (nonatomic, retain)     UIButton        *maskingButton;
@end

@implementation PullDown
@synthesize values, table, delegate, maskingButton, offset, numberOfRows, images, popupWidth;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupProgrammatically];
    }
    return self;
}

// ╔══════════════════════════════════════════════════════════════
// ║ constructed from .xib
// ╚══════════════════════════════════════════════════════════════
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupFromXIB];
    }
    return self;
}

// ╔══════════════════════════════════════════════════════════════
// ║ Create sub controls programmatically
// ╚══════════════════════════════════════════════════════════════
- (void)setupProgrammatically {
    self.numberOfRows = 4;
    self.clipsToBounds = NO;
    self.backgroundColor = [UIColor whiteColor];
    
    UITextField *field = [[[UITextField alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)] autorelease];
    field.tag = 1;
    field.leftViewMode = UITextFieldViewModeAlways;
    UIView *padding = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, field.frame.size.height)] autorelease];
    field.leftView = padding;
    field.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;

    UIButton *button = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)] autorelease];
    button.tag = 2;
    UIEdgeInsets insets = {2, 0, 0, 8};
    button.titleEdgeInsets = insets;
    [button setTitle:@"▼" forState:UIControlStateNormal];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [self addSubview:field];
    [self addSubview:button];
}

// ╔══════════════════════════════════════════════════════════════
// ║ Initialize assuming sub controls are present in the xib file
// ╚══════════════════════════════════════════════════════════════
- (void)setupFromXIB {
    self.clipsToBounds = NO;
    UITextField *field = (UITextField *)[self viewWithTag:1];
    field.leftViewMode = UITextFieldViewModeAlways;
    UIView *padding = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, field.frame.size.height)] autorelease];
    field.leftView = padding;
    self.numberOfRows = 6;
}

- (void)setFont:(UIFont *)font {
    UITextField *field = (UITextField *)[self viewWithTag:1];
    field.font = font;
    UIButton *button = (UIButton *)[self viewWithTag:2];
    button.titleLabel.font = font;
}

- (void)setColor:(UIColor *)color {
    UITextField *field = (UITextField *)[self viewWithTag:1];
    field.textColor = color;
    UIButton *button = (UIButton *)[self viewWithTag:2];
    [button setTitleColor:color forState:UIControlStateNormal];
}

// ╔══════════════════════════════════════════════════════════════
// ║ Pass in the array of values to display in the drop down
// ╚══════════════════════════════════════════════════════════════
- (void)setValues:(NSArray *)newValues {
    NSMutableArray *normalized = [NSMutableArray arrayWithCapacity:newValues.count];
    for (NSObject *value in newValues) {
        if ([value isKindOfClass:NSString.class]) {
            [normalized addObject:value];
        } else {
            [normalized addObject:value.description];
        }
    }
    if (values) {
        [values release];
    };
    values = [normalized retain];
    UITextField *field = (UITextField *)[self viewWithTag:1];
    field.text = nil;
    UIButton *button = (UIButton *)[self viewWithTag:2];
    if (values.count > 1) {
        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        field.delegate = self;
    } else {
        button.hidden = YES;
        field.enabled = NO;
    }
    [table reloadData];
}

// ╔══════════════════════════════════════════════════════════════
// ║ Return the current, selected value
// ╚══════════════════════════════════════════════════════════════
- (NSString *)text {
    UITextField *field = (UITextField *)[self viewWithTag:1];
    return field.text;
}

// ╔══════════════════════════════════════════════════════════════
// ║ Set the display string or current value
// ╚══════════════════════════════════════════════════════════════
- (void)setText:(NSString *)text {
    UITextField *field = (UITextField *)[self viewWithTag:1];
    field.text = text;
}

- (void)buttonTapped:(UIButton *)button {
    UIWindow *window = self.window;
    int rigthGap = self.frame.size.height;
    int width = self.popupWidth ? self.popupWidth : self.frame.size.width - rigthGap;
    CGRect tableFrame = CGRectMake(self.frame.origin.x + (self.frame.size.width - width - rigthGap), self.frame.origin.y, width, self.frame.size.height*self.numberOfRows);
    CGRect startFrame = CGRectMake(self.frame.origin.x + (self.frame.size.width - width - rigthGap), self.frame.origin.y, width, self.frame.size.height);
    tableFrame = [[self superview] convertRect:tableFrame toView:window];
    startFrame = [[self superview] convertRect:startFrame toView:window];
    if (table) {
        [UIView animateWithDuration:0.1 animations:^{
            table.frame = startFrame;
        } completion:^(BOOL finished) {
            [table removeFromSuperview];
            [maskingButton removeFromSuperview];
            self.table = nil;
            self.maskingButton = nil;
        }];
    } else {
        // First add the 'masking' button
        maskingButton = [[UIButton alloc] initWithFrame:window.bounds];
        [maskingButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];

        table = [[UITableView alloc] initWithFrame:startFrame style:UITableViewStylePlain];
        table.rowHeight = self.frame.size.height;
        table.separatorColor = [UIColor colorWithCGColor:self.layer.borderColor];
        table.delegate = self;
        table.dataSource = self;
        table.backgroundColor = self.backgroundColor;
        table.layer.cornerRadius = self.layer.cornerRadius;
        table.layer.borderWidth = self.layer.borderWidth;
        table.layer.borderColor = self.layer.borderColor;

        if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft) {
            CGAffineTransform t = CGAffineTransformMakeRotation(-90.0 * M_PI / 180.0);
            t = CGAffineTransformTranslate(t, -19, 19);
            table.transform = t;
        } else if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight) {
            CGAffineTransform t = CGAffineTransformMakeRotation(90.0 * M_PI / 180.0);
            t = CGAffineTransformTranslate(t, -19, 19);
            table.transform = t;
        } else if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortraitUpsideDown) {
            CGAffineTransform t = CGAffineTransformMakeRotation(180.0 * M_PI / 180.0);
            t = CGAffineTransformTranslate(t, -19, 19);
            table.transform = t;
        }
        [window addSubview:maskingButton];
        [window addSubview:table];
        [UIView animateWithDuration:0.1 animations:^{
            table.frame = tableFrame;
        } completion:^(BOOL finished) {
            [table flashScrollIndicators];
            [self preselect];
        }];
    }
}

- (void)preselect {
    UITextField *field = (UITextField *)[self viewWithTag:1];
    if (field.text.length == 0) {
        return;
    }
    for (int row=0; row<values.count; row++) {
        NSString *val = [values objectAtIndex:row];
        if ([val isEqualToString:field.text]) {
            [table selectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
            break;
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return values.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = @"PullDownCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        UITextField *field = (UITextField *)[self viewWithTag:1];
        cell.textLabel.font = field.font;
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.textLabel.textColor = field.textColor;
    }
    cell.textLabel.text = [self.values objectAtIndex:indexPath.row];
    if (images) {
        cell.imageView.image = [images objectAtIndex:indexPath.row];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self _release];
}

- (void)_release {
    @autoreleasepool {
        UITextField *field = (UITextField *)[self viewWithTag:1];
        field.text = [table cellForRowAtIndexPath:table.indexPathForSelectedRow].textLabel.text;
        [self buttonTapped:nil];
        if (delegate && [delegate respondsToSelector:@selector(pullDown:didSelect:atIndex:)]) {
            SEL sel = @selector(pullDown:didSelect:atIndex:);
            NSInvocation* inv = [NSInvocation invocationWithMethodSignature:[delegate methodSignatureForSelector:sel]];
            [inv setTarget:delegate];
            [inv setSelector:sel];
            [inv setArgument:&self atIndex:2];
            NSString *text = field.text;
            [inv setArgument:&text atIndex:3];
            int index = table.indexPathForSelectedRow.row;
            [inv setArgument:&index atIndex:4];
            [inv invoke];
        } else if (delegate && [delegate respondsToSelector:@selector(pullDown:didSelect:)]) {
            [delegate performSelector:@selector(pullDown:didSelect:) withObject:self withObject:field.text];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (delegate && [delegate respondsToSelector:@selector(pullDownShouldReturn:)]) {
        id result =  [delegate performSelector:@selector(pullDownShouldReturn:) withObject:self];
        return (BOOL)result;
    } else {
        return YES;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (delegate && [delegate respondsToSelector:@selector(pullDown:shouldChangeCharactersInRange:replacementString:)]) {
        SEL sel = @selector(pullDown:shouldChangeCharactersInRange:replacementString:);
        NSInvocation* inv = [NSInvocation invocationWithMethodSignature:[delegate methodSignatureForSelector:sel]];
        [inv setTarget:delegate];
        [inv setSelector:sel];
        [inv setArgument:&self atIndex:2];
        [inv setArgument:&range atIndex:3];
        [inv setArgument:&string atIndex:4];
        [inv invoke];
        NSUInteger length = [[inv methodSignature] methodReturnLength];
        void *buffer = (void *)malloc(length);
        [inv getReturnValue:buffer];
        return (BOOL)buffer;
    } else {
        return YES;
    }
}

- (BOOL)becomeFirstResponder {
    UITextField *field = (UITextField *)[self viewWithTag:1];
    return [field becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
    UITextField *field = (UITextField *)[self viewWithTag:1];
    return [field resignFirstResponder];
}

- (void)dealloc {
    [table release];
    [maskingButton release];
    [values release];
    [images release];
    [super dealloc];
}
@end
