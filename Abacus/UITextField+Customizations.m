
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>
#import "UITextField+Customizations.h"

@implementation UITextField (Customizations)

- (void)customize {
    UIView *padding = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, self.frame.size.height)] autorelease];
    self.leftViewMode = UITextFieldViewModeAlways;
    self.leftView = padding;
    self.layer.cornerRadius = 5;
    self.layer.borderWidth = 0.5;
    self.layer.borderColor = [[UIColor colorWithWhite:0.6 alpha:1.0] CGColor];
    self.backgroundColor = [UIColor whiteColor];
}

@end
