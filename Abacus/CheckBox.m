
#import <AudioToolbox/AudioToolbox.h>
#import "CheckBox.h"

@implementation CheckBox

- (id)initWithFrame:(CGRect)rect {
    self = [super initWithFrame:rect];
    [self addTarget:self action:@selector(tapped) forControlEvents:UIControlEventTouchDown];    
    return self;
}

- (void)listenToTaps {
    [self addTarget:self action:@selector(tapped) forControlEvents:UIControlEventTouchDown];
}

- (void)awakeFromNib {
	[super awakeFromNib];
    [self addTarget:self action:@selector(tapped) forControlEvents:UIControlEventTouchDown];
}

// Checkboxes return their selected state as the 'action' for logging
- (int)activityAction {
    return self.selected;
}

- (void)tapped {
    // Toggle my state
    //AudioServicesPlaySystemSound(1104);
    self.selected = !self.selected;
}

- (void)dealloc {
    [super dealloc];
}

@end