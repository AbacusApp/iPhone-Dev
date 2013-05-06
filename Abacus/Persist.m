//
//  CalculatorViewController.m
//  Abacus
//
//  Created by Graham Savage on 5/3/13.
//  Copyright (c) 2013 Graham Savage. All rights reserved.
//


#import "Persist.h"

@implementation Persist

+ (NSString *)prependAppNameToKey:(NSString *)key {
    NSString *name = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleNameKey];
    return [name stringByAppendingFormat:@"-%@", key];
}

// If we are running in the simulator, the keychain access API does not work (does not even compile), so we use the UserDefaults instead
#if TARGET_IPHONE_SIMULATOR
+ (void)setValue:(NSString *)value forKey:(NSString *)key  secure:(BOOL)secure{
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs setObject:value forKey:[self prependAppNameToKey:key]];
}

+ (NSString *)valueFor:(NSString *)key  secure:(BOOL)secure{
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	return  [prefs objectForKey:[self prependAppNameToKey:key]];
}

+ (void)deleteValueForKey:(NSString *)key  secure:(BOOL)secure{
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs removeObjectForKey:[self prependAppNameToKey:key]];
}
#else
+ (NSMutableDictionary *)defaultDictionary:(NSString *)key {
	NSMutableDictionary *defaults = [[[NSMutableDictionary alloc] init] autorelease];
	
	[defaults setObject:(id)kSecClassInternetPassword forKey:(id)kSecClass];
	[defaults setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];			// Return only first match
	[defaults setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];				// return item's value
    // The data in the keychain item can be accessed only while the device is unlocked by the user. 
    // This is recommended for items that need to be accesible only while the application is in the foreground. 
    // Items with this attribute do not migrate to a new device or new installation. 
    // Thus, after restoring from a backup, these items will not be present
	[defaults setObject:(id)kSecAttrAccessibleWhenUnlockedThisDeviceOnly forKey:(id)kSecAttrAccessible];
	
	[defaults setObject:key forKey:(id)kSecAttrAccount];                            // Set the unique key, we are using kSecAttrAccount
	return defaults;
}

+ (NSString *)valueFor:(NSString *)key  secure:(BOOL)secure {
    if (secure) {
        NSData *results = nil;
        NSMutableDictionary *search = [Persist defaultDictionary:[self prependAppNameToKey:key]];
        
        if (SecItemCopyMatching((CFDictionaryRef)search, (CFTypeRef *)&results) == noErr) {
            // Item found
            NSString *value = [[[NSString alloc] initWithBytes:[results bytes] length:[results length] encoding:NSUTF8StringEncoding] autorelease];
            return value;
        } else {
            // Item not found
            return nil;
        }
    } else {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        return  [prefs objectForKey:[self prependAppNameToKey:key]];
    }
}

+ (void)setValue:(NSString *)value forKey:(NSString *)key  secure:(BOOL)secure {
    if (!value || !key) {
        return;
    }
    if (secure) {
        if ([Persist valueFor:[self prependAppNameToKey:key] secure:secure]) {
            [Persist deleteValueForKey:key secure:secure];
            [Persist setValue:value forKey:[self prependAppNameToKey:key] secure:secure];
        } else {
            // Add new item
            NSMutableDictionary *item = [Persist defaultDictionary:[self prependAppNameToKey:key]];
            [item setObject:[value dataUsingEncoding:NSUTF8StringEncoding] forKey:(id)kSecValueData];
            [item removeObjectForKey:(id)kSecMatchLimit];	// remove keys that cannot be in there for an add
            [item removeObjectForKey:(id)kSecReturnData];	// remove keys that cannot be in there for an add
            [item removeObjectForKey:(id)kSecReturnAttributes];	// remove keys that cannot be in there for an add
            SecItemAdd((CFDictionaryRef)item, NULL);
        }
    } else {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:value forKey:[self prependAppNameToKey:key]];
    }
}

+ (void)deleteValueForKey:(NSString *)key  secure:(BOOL)secure {
    if (secure) {
        NSMutableDictionary *search = [Persist defaultDictionary:[self prependAppNameToKey:key]];
        [search removeObjectForKey:(id)kSecMatchLimit];	// remove keys that cannot be in there for an add
        [search removeObjectForKey:(id)kSecReturnData];	// remove keys that cannot be in there for an add
        [search removeObjectForKey:(id)kSecReturnAttributes];	// remove keys that cannot be in there for an add
        SecItemDelete((CFDictionaryRef)search);
    } else {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs removeObjectForKey:[self prependAppNameToKey:key]];
    }
}
#endif

@end