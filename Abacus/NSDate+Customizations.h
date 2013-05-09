//
//  NSDate+Customizations.h
//  Abacus
//
//  Created by Graham Savage on 5/9/13.
//  Copyright (c) 2013 Graham Savage. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Customizations)
- (NSString *)asDatabaseString;
- (NSString *)asDisplayString;
+ (NSDate *)dateForDisplayString:(NSString *)text;
+ (NSDate *)dateForDatabaseString:(NSString *)text;
@end
