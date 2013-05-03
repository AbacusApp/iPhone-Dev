
#import <UIKit/UIKit.h>

@interface PullDown : UIView
@property   (nonatomic, retain)     NSArray     *values;
@property   (nonatomic, retain)     NSArray     *images;
@property   (nonatomic, retain)     NSString    *text;
@property   (nonatomic, assign)     IBOutlet id delegate;
@property   (nonatomic, assign)     int         offset;
@property   (nonatomic, assign)     int         numberOfRows;
@property   (nonatomic, assign)     int         popupWidth;

- (void)setFont:(UIFont *)font;
- (void)setColor:(UIColor *)color;
@end
