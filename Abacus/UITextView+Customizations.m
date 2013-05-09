//
//  UITextView+Customizations.m
//  Abacus
//
//  Created by Graham Savage on 5/9/13.
//  Copyright (c) 2013 Graham Savage. All rights reserved.
//

#import "UITextView+Customizations.h"

@implementation UITextView (Customizations)
UILabel *placeholderLabel = nil;

- (void)awakeFromNib {
    [super awakeFromNib];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChange:) name:UITextViewTextDidChangeNotification object:nil];
    placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(9, 10, self.bounds.size.width, 20)];
    placeholderLabel.backgroundColor = [UIColor clearColor];
    placeholderLabel.textColor = [UIColor lightGrayColor];
    placeholderLabel.font = self.font;
    placeholderLabel.text = self.description;
    [self addSubview:placeholderLabel];
}

- (void)setPlaceholder:(NSString *)text {
    placeholderLabel.text = text;
}

- (void)didChange:(NSNotification *)note {
    if (self.text.length) {
        [placeholderLabel removeFromSuperview];
    } else {
        [self addSubview:placeholderLabel];
    }
}

@end
