//
//  NSDate+Customizations.m
//  Abacus
//
//  Created by Graham Savage on 5/9/13.
//  Copyright (c) 2013 Graham Savage. All rights reserved.
//

#import "NSDate+Customizations.h"

@implementation NSDate (Customizations)
NSDateFormatter *dateFormatter;

+ (void)load {
    [NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehavior10_4];
    dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease];
    [dateFormatter setLocale:locale];
}

- (NSString *)asDatabaseString {
	[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	return [dateFormatter stringFromDate:self];
}

- (NSString *)asDisplayString {
	[dateFormatter setDateFormat:@"M/d/yyyy"];
	return [dateFormatter stringFromDate:self];
}

+ (NSDate *)dateForString:(NSString *)text {
	[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	return [dateFormatter dateFromString:text];
}
@end
