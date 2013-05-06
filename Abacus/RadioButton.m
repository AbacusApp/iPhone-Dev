//
//  CalculatorViewController.m
//  Abacus
//
//  Created by Graham Savage on 5/3/13.
//  Copyright (c) 2013 Graham Savage. All rights reserved.
//


#import "RadioButton.h"

@implementation RadioButton

- (id)initWithFrame:(CGRect)rect {
    self = [super initWithFrame:rect];
    [self addTarget:self action:@selector(tapped) forControlEvents:UIControlEventTouchDown];    
    return self;
}

- (void)awakeFromNib {
	[super awakeFromNib];
    [self addTarget:self action:@selector(tapped) forControlEvents:UIControlEventTouchDown];
}

// Radio buttons return their selected state as the 'action' for logging
- (int)activityAction {
    return self.selected;
}

// When this button is to be selected programmatically, deselect its siblings first
// When it is to be deselected programmatically, just do it
- (void)setSelected:(BOOL)state {
    if (state) {
        NSArray *all = [self.superview subviews];
        for (UIView *other in all) {
            if ([other isKindOfClass:RadioButton.class]) {
                ((RadioButton *)other).selected = NO;
            }
        }
    }
    [super setSelected:state];
}

// Returns the radiobutton that is selected in this view. Returns nil if none are selected
- (RadioButton *)selectedRadioButton {
    NSArray *all = [self.superview subviews];
    for (UIView *other in all) {
        if ([other isKindOfClass:RadioButton.class] && ((RadioButton *)other).selected) {
            return ((RadioButton *)other);
        }
    }
    return nil;
}

- (void)tapped {
    // If I am off then switch me on
    if (!self.selected) {
        self.selected = YES;

        // Get a list of all other radiobutons in this view, and switch them off
        NSArray *all = [self.superview subviews];
        for (UIView *other in all) {
            if ([other isKindOfClass:RadioButton.class] && other!=self) {
                ((RadioButton *)other).selected = NO;
            }
        }
    }
}

- (void)dealloc {
    [super dealloc];
}

@end