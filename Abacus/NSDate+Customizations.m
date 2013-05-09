//
//  NSDate+Customizations.m
//  Abacus
//
//  Created by Graham Savage on 5/9/13.
//  Copyright (c) 2013 Graham Savage. All rights reserved.
//

#import "NSDate+Customizations.h"

#define DISPLAY_FORMAT  @"MMM d yyyy"

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

+ (NSDate *)dateForDatabaseString:(NSString *)text {
	[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	return [dateFormatter dateFromString:text];
}

- (NSString *)asDisplayString {
	[dateFormatter setDateFormat:DISPLAY_FORMAT];
	return [dateFormatter stringFromDate:self];
}

+ (NSDate *)dateForDisplayString:(NSString *)text {
	[dateFormatter setDateFormat:DISPLAY_FORMAT];
	return [dateFormatter dateFromString:text];
}

@end
