//
//  CalculatorViewController.m
//  Abacus
//
//  Created by Graham Savage on 5/3/13.
//  Copyright (c) 2013 Graham Savage. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <Security/Security.h>

@interface Persist : NSObject {
}

+ (NSString *)prependAppNameToKey:(NSString *)key;
+ (NSString *)valueFor:(NSString *)key secure:(BOOL)secure;
+ (void)setValue:(NSString *)value forKey:(NSString *)key secure:(BOOL)secure;
+ (void)deleteValueForKey:(NSString *)key secure:(BOOL)secure;
@end