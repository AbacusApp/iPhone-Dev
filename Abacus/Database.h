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
    ProfessionIDUndefined = -1,
    ProfessionIDPhotographer = 1,
    ProfessionIDWaiter = 2,
} ProfessionID;

typedef struct {
    NSString        *name;
    ProfessionID    ID;
} Profession;

extern Profession Professions[];

@interface Database : NSObject
@property (nonatomic, assign)	sqlite3		*database;

+ (BOOL)dbExists;
+ (void)makeDB;
+ (NSArray *)professions;
@end
