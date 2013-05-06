//
//  CalculatorViewController.m
//  Abacus
//
//  Created by Graham Savage on 5/3/13.
//  Copyright (c) 2013 Graham Savage. All rights reserved.
//

#import "UIImage+Retina4.h"
#import <objc/runtime.h>

static Method origImageNamedMethod = nil;

@implementation UIImage (Retina4)

+ (void)initialize {
    origImageNamedMethod = class_getClassMethod(self, @selector(imageNamed:));
    method_exchangeImplementations(origImageNamedMethod, class_getClassMethod(self, @selector(retina4ImageNamed:)));
}

+ (UIImage *)retina4ImageNamed:(NSString *)imageName {
    NSMutableString *imageNameMutable = [imageName mutableCopy];
    NSRange retinaAtSymbol = [imageName rangeOfString:@"@"];
    if (retinaAtSymbol.location != NSNotFound) {
        [imageNameMutable insertString:@"-568h" atIndex:retinaAtSymbol.location];
    } else {
        if ([self isRetina4]) {
            NSRange dot = [imageName rangeOfString:@"." options:NSBackwardsSearch];
            if (dot.location != NSNotFound) {
                [imageNameMutable insertString:@"-568h@2x" atIndex:dot.location];
            } else {
                [imageNameMutable appendString:@"-568h@2x"];
            }
        }
    }
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:imageNameMutable ofType:nil];
    if (imagePath) {
        return [UIImage retina4ImageNamed:imageNameMutable];
    } else {
        return [UIImage retina4ImageNamed:imageName];
    }
    return nil;
}

+ (BOOL)isRetina4 {
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    if ([UIScreen mainScreen].scale == 2.f && screenHeight == 568.0f) {
        return YES;
    }
    return NO;
}
@end
