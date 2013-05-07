//
//  Database.m
//  Abacus
//
//  Created by Graham Savage on 5/7/13.
//  Copyright (c) 2013 Graham Savage. All rights reserved.
//

#import "Database.h"

Profession Professions[] = {
    {@"Undefined", -1},
    {@"Photographer", 1}
};

static Database *handler = nil;

@implementation Database
@synthesize database;

// ┌────────────────────────────────────────────────────────────────────────────────────────────────────
// │ Create the db if it does not already exist
// └────────────────────────────────────────────────────────────────────────────────────────────────────
+ (void)initialize {
    handler = [[Database alloc] init];
    if (![self dbExists]) {
        [self makeDB];
    }
}

// ┌────────────────────────────────────────────────────────────────────────────────────────────────────
// │ Construct a local path name for the db
// └────────────────────────────────────────────────────────────────────────────────────────────────────
+ (NSString *)databasePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docs = [paths objectAtIndex:0];
    return [docs stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.s3db", [[self class] description]]];
}

// ┌────────────────────────────────────────────────────────────────────────────────────────────────────
// │ Verify that db exists and is non-zero size
// └────────────────────────────────────────────────────────────────────────────────────────────────────
+ (BOOL)dbExists {
	NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL exists = [fileManager fileExistsAtPath:[self databasePath]];
    if (exists) {
        // Check to see that it is not zero bytesize
        NSData *contents = [fileManager contentsAtPath:[self databasePath]];
        if (!contents || [contents length]==0) {
            exists = NO;
        }
    }
    return exists;
}

// ┌────────────────────────────────────────────────────────────────────────────────────────────────────
// │ Create an empty db
// └────────────────────────────────────────────────────────────────────────────────────────────────────
+ (void)makeDB {
    sqlite3 *db;
    NSString *file = [self databasePath];
    sqlite3_open_v2([file cStringUsingEncoding:NSUTF8StringEncoding], &db, SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE, NULL);
	sqlite3_stmt *statement;
    NSString *sqlString = [NSString stringWithFormat:
                           @"CREATE TABLE \"User\" (\
                           \"FirstName\" TEXT DEFAULT NULL,\
                           \"LastName\" TEXT DEFAULT NULL,\
                           \"Profession\" INTEGER DEFAULT -1,\
                           \"Email\" TEXT DEFAULT NULL,\
                           \"Cell\" TEXT DEFAULT NULL,\
                           \"Address1\" INTEGER DEFAULT NULL,\
                           \"Address2\" INTEGER DEFAULT NULL,\
                           \"City\" TEXT DEFAULT NULL,\
                           \"State\" REAL DEFAULT 0,\
                           \"Country\" TEXT DEFAULT NULL,\
                           \"Zip\" TEXT DEFAULT NULL,\
                           \"HourlyRate\" REAL DEFAULT 0\
                           )"];
	const char *sql = [sqlString UTF8String];
	if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) == SQLITE_OK) {
		while (sqlite3_step(statement) != SQLITE_DONE) {}
	}
	sqlite3_finalize(statement);
    sqlite3_close(db);
}

+ (void)open {
    sqlite3 *temp;
    sqlite3_open([[self databasePath] UTF8String], &temp);
    handler.database = temp;
}

+ (void)close {
    sqlite3_close(handler.database);
	handler.database = nil;
}

+ (void)remove {
	[self close];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	[fileManager removeItemAtPath:[self databasePath] error:nil];
}

+ (NSString *)stringForColumn:(int)column inStatement:(sqlite3_stmt *)statement {
    const char *value = (const char *)sqlite3_column_text(statement, column);
    if (value) {
        return [NSString stringWithUTF8String:value];
    } else {
        return nil;
    }
}

+ (NSArray *)professions {
    NSMutableArray *list = [NSMutableArray array];
    for (int i=0; i<sizeof(Professions)/sizeof(Professions[0]); i++) {
        [list addObject:Professions[i].name];
    }
    return list;
}

- (id)init {
    self = [super init];
    if (self) {
        self.database = nil;
    }
    return self;
}

- (void)dealloc {
    [Database close];
    [handler release];
    [super dealloc];
}

@end
