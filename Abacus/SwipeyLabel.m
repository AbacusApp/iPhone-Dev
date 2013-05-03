//
//  SwipeyLabel.m
//  Abacus
//
//  Created by Graham Savage on 5/3/13.
//  Copyright (c) 2013 Graham Savage. All rights reserved.
//

#import "SwipeyLabel.h"

@interface SwipeyLabel ()
@property   (nonatomic, assign)     CGPoint     previousPosition;
@end

@implementation SwipeyLabel
@synthesize previousPosition, value, minimum, maximum, increment;

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.value = 10;
    self.minimum = 10;
    self.maximum = 500;
    self.increment = 1;
    [self updateDisplay];
    UIPanGestureRecognizer *pan = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)] autorelease];
    [self addGestureRecognizer:pan];
}

- (void)setValue:(double)newValue {
    value = newValue;
    [self updateDisplay];
}

- (void)pan:(UIPanGestureRecognizer *)gr {
    CGPoint pt = [gr translationInView:self];
    double velocity = [gr velocityInView:self].y;
    velocity = abs(velocity);
    NSLog(@"%f", velocity);
    if (self.previousPosition.y > pt.y) {
        self.value += velocity / 300;
        if (self.value > self.maximum) {
            self.value = self.maximum;
        }
    } else if (self.previousPosition.y < pt.y) {
        self.value -= velocity / 300;
        if (self.value < self.minimum) {
            self.value = self.minimum;
        }
    }
    self.previousPosition = pt;
    [self updateDisplay];
}

- (void)updateDisplay {
    self.text = [NSString stringWithFormat:@"$%.0f", self.value];
}

@end
