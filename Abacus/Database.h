//
//  Database.h
//  Abacus
//
//  Created by Graham Savage on 5/7/13.
//  Copyright (c) 2013 Graham Savage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

typedef enum {
    ProfessionIDUndefined = 0,
    ProfessionIDPhotographer = 1,
    ProfessionIDWaiter = 2,
} ProfessionID;

typedef enum {
    StateIDUndefined = 0,
    StateIDAlabama = 1,
    StateIDAlaska = 2,
} StateID;

@interface User : NSObject
@property   (nonatomic, retain)     NSString        *firstName, *lastName, *address1, *address2, *city, *zip, *cell, *country;
@property   (nonatomic, assign)     double          hourlyRate;
@property   (nonatomic, assign)     ProfessionID    professionID;
@property   (nonatomic, assign)     StateID         stateID;
@end

@interface Database : NSObject
@property (nonatomic, assign)	sqlite3		*database;

+ (BOOL)dbExists;
+ (void)makeDB;
+ (NSArray *)professions;
+ (NSString *)nameForProfession:(ProfessionID)professionID;
+ (ProfessionID)idForProfessionName:(NSString *)name;
+ (void)setUser:(User *)user;
+ (void)updateUser:(User *)user;
+ (User *)user;
@end
