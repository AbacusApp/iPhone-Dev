
#import <Foundation/Foundation.h>
#import <Security/Security.h>

@interface Persist : NSObject {
}

+ (NSString *)prependAppNameToKey:(NSString *)key;
+ (NSString *)valueFor:(NSString *)key secure:(BOOL)secure;
+ (void)setValue:(NSString *)value forKey:(NSString *)key secure:(BOOL)secure;
+ (void)deleteValueForKey:(NSString *)key secure:(BOOL)secure;
@end