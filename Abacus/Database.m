//
//  Database.m
//  Abacus
//
//  Created by Graham Savage on 5/7/13.
//  Copyright (c) 2013 Graham Savage. All rights reserved.
//

#import "Database.h"
#import "NSDate+Customizations.h"

#define DB_VERSION      @"1.0.0"

static  Database        *handler = nil;
static  NSDictionary    *professions = nil;
static  NSDictionary    *states = nil;

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
    professions = [[NSDictionary dictionaryWithObjectsAndKeys:
                    @"Actor / Actress", [NSNumber numberWithInt:ProfessionIDActorActress],
                    @"Animator", [NSNumber numberWithInt:ProfessionIDAnimator],
                    @"Concept Artist", [NSNumber numberWithInt:ProfessionIDConceptArtist],
                    @"Copywriter - Advertising", [NSNumber numberWithInt:ProfessionIDCopywriterAdvertising],
                    @"Copywriter - Creative", [NSNumber numberWithInt:ProfessionIDCopywriterCreative],
                    @"Creative Instructor", [NSNumber numberWithInt:ProfessionIDCreativeInstructor],
                    @"Developer - Android", [NSNumber numberWithInt:ProfessionIDDeveloperAndroid],
                    @"Developer - Blackberry", [NSNumber numberWithInt:ProfessionIDDeveloperBlackberry],
                    @"Developer - iOS", [NSNumber numberWithInt:ProfessionIDDeveloperiOS],
                    @"Developer - Mac / PC", [NSNumber numberWithInt:ProfessionIDDeveloperMacPC],
                    @"Developer - Web", [NSNumber numberWithInt:ProfessionIDDeveloperWeb],
                    @"Developer - Windows Phone", [NSNumber numberWithInt:ProfessionIDDeveloperWindowsPhone],
                    @"Event Planner", [NSNumber numberWithInt:ProfessionIDEventPlanner],
                    @"Fashion Designer", [NSNumber numberWithInt:ProfessionIDFashionDesigner],
                    @"Film Director", [NSNumber numberWithInt:ProfessionIDFilmDirector],
                    @"Filmmaker", [NSNumber numberWithInt:ProfessionIDFilmaker],
                    @"Graphic Designer", [NSNumber numberWithInt:ProfessionIDGraphicDesigner],
                    @"Illustrator - Digital", [NSNumber numberWithInt:ProfessionIDIllustratorDigital],
                    @"Illustrator - Traditional", [NSNumber numberWithInt: ProfessionIDIllustratorTraditional],
                    @"Merchandiser", [NSNumber numberWithInt:ProfessionIDMerchandiser],
                    @"Model - Photography", [NSNumber numberWithInt:ProfessionIDModelPhotography],
                    @"Model - Video", [NSNumber numberWithInt:ProfessionIDModelVideo],
                    @"Motion Graphics Artist", [NSNumber numberWithInt:ProfessionIDMotionGraphicsArtist],
                    @"Musician", [NSNumber numberWithInt:ProfessionIDMusician],
                    @"Photographer", [NSNumber numberWithInt:ProfessionIDPhotographer],
                    @"Producer", [NSNumber numberWithInt:ProfessionIDProducer],
                    @"UI / UX Designer", [NSNumber numberWithInt:ProfessionIDUIUXDesigner],
                    @"Video Game Designer", [NSNumber numberWithInt:ProfessionIDVideoGameDesigner],
                    @"Video Production Artist", [NSNumber numberWithInt:ProfessionIDVideoProductionArtist],
                    @"Virtual Assistant", [NSNumber numberWithInt:ProfessionIDVirtualAssistant],
                    @"Web Designer", [NSNumber numberWithInt:ProfessionIDWebDesigner],
                    @"Other", [NSNumber numberWithInt:ProfessionIDOther],
                   nil] retain];
    
    states = [[NSDictionary dictionaryWithObjectsAndKeys:
              @"Alabama", [NSNumber numberWithInt:StateIDAlabama],
              @"Alaska", [NSNumber numberWithInt:StateIDAlaska],
              nil] retain];    
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

    // Meta TABLE
	sqlite3_stmt *statement;
    NSString *sqlString = [NSString stringWithFormat:
                           @"CREATE TABLE \"Meta\" (\
                           \"DBVersion\" TEXT DEFAULT NULL,\
                           \"AppVersion\" TEXT DEFAULT NULL\
                           )"];
	const char *sql = [sqlString UTF8String];
	if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) == SQLITE_OK) {
		while (sqlite3_step(statement) != SQLITE_DONE) {}
	}
	sqlite3_finalize(statement);

    // User TABLE
    sqlString = [NSString stringWithFormat:
                           @"CREATE TABLE \"User\" (\
                           \"FirstName\" TEXT DEFAULT NULL,\
                           \"LastName\" TEXT DEFAULT NULL,\
                           \"Profession\" INTEGER DEFAULT 0,\
                           \"Email\" TEXT DEFAULT NULL,\
                           \"Cell\" TEXT DEFAULT NULL,\
                           \"Address1\" INTEGER DEFAULT NULL,\
                           \"Address2\" INTEGER DEFAULT NULL,\
                           \"City\" TEXT DEFAULT NULL,\
                           \"State\" INTEGER DEFAULT -1,\
                           \"Country\" TEXT DEFAULT NULL,\
                           \"Zip\" TEXT DEFAULT NULL,\
                           \"HourlyRate\" REAL DEFAULT 0\
                           )"];
	sql = [sqlString UTF8String];
	if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) == SQLITE_OK) {
		while (sqlite3_step(statement) != SQLITE_DONE) {}
	}
	sqlite3_finalize(statement);
    
    // Projects TABLE
    sqlString = [NSString stringWithFormat:
                           @"CREATE TABLE \"Projects\" (\
                           \"GUID\" TEXT DEFAULT NULL,\
                           \"Name\" TEXT DEFAULT NULL,\
                           \"Description\" TEXT DEFAULT NULL,\
                           \"StartingDate\" TEXT DEFAULT NULL,\
                           \"EndingDate\" TEXT DEFAULT NULL,\
                           \"InitialQuote\" REAL DEFAULT 0,\
                           \"Status\" INTEGER DEFAULT 0,\
                           \"HoursTaken\" REAL DEFAULT 0,\
                           \"AdditionalExpenses\" REAL DEFAULT 0,\
                           \"Profitability\" INTEGER DEFAULT 0\
                           )"];
	sql = [sqlString UTF8String];
	if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) == SQLITE_OK) {
		while (sqlite3_step(statement) != SQLITE_DONE) {}
	}
	sqlite3_finalize(statement);
    sqlite3_close(db);
    [self open];
    // Set the version strings into the Meta table
    sqlString = [NSString stringWithFormat:@"INSERT INTO \"Meta\" (DBVersion,AppVersion) VALUES(\"%@\",\"%@\")", DB_VERSION, [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey]];
	sql = [sqlString UTF8String];
	if (sqlite3_prepare_v2(handler.database, sql, -1, &statement, NULL) == SQLITE_OK) {
		while (sqlite3_step(statement) != SQLITE_DONE) {}
	}
	sqlite3_finalize(statement);

}

// ┌────────────────────────────────────────────────────────────────────────────────────────────────────
// │ Open the db - get handle
// └────────────────────────────────────────────────────────────────────────────────────────────────────
+ (void)open {
    sqlite3 *temp;
    sqlite3_open([[self databasePath] UTF8String], &temp);
    handler.database = temp;
}

// ┌────────────────────────────────────────────────────────────────────────────────────────────────────
// │ close the db
// └────────────────────────────────────────────────────────────────────────────────────────────────────
+ (void)close {
    sqlite3_close(handler.database);
	handler.database = nil;
}

// ┌────────────────────────────────────────────────────────────────────────────────────────────────────
// │ delete the db file
// └────────────────────────────────────────────────────────────────────────────────────────────────────
+ (void)remove {
	[self close];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	[fileManager removeItemAtPath:[self databasePath] error:nil];
}

// ┌────────────────────────────────────────────────────────────────────────────────────────────────────
// │ return a string from a result
// └────────────────────────────────────────────────────────────────────────────────────────────────────
+ (NSString *)stringForColumn:(int)column inStatement:(sqlite3_stmt *)statement {
    const char *value = (const char *)sqlite3_column_text(statement, column);
    if (value) {
        return [NSString stringWithUTF8String:value];
    } else {
        return nil;
    }
}

// ┌────────────────────────────────────────────────────────────────────────────────────────────────────
// │ Create a random guid-format string
// └────────────────────────────────────────────────────────────────────────────────────────────────────
+ (NSString *)GUID {
    NSString *result = @"";
    result = [result stringByAppendingString:[self uuidSectionOfLength:8]];
    result = [result stringByAppendingString:@"-"];
    result = [result stringByAppendingString:[self uuidSectionOfLength:4]];
    result = [result stringByAppendingString:@"-"];
    result = [result stringByAppendingString:[self uuidSectionOfLength:4]];
    result = [result stringByAppendingString:@"-"];
    result = [result stringByAppendingString:[self uuidSectionOfLength:4]];
    result = [result stringByAppendingString:@"-"];
    result = [result stringByAppendingString:[self uuidSectionOfLength:12]];
    return result;
}

+ (NSString *)uuidSectionOfLength:(int)length {
    NSString *validCharacters = @"0123456789abcdef";
    
    NSString *result = @"";
    for(int i=0; i<length; i++) {
        int rnd = arc4random() % 16;
        result = [result stringByAppendingFormat:@"%c", [validCharacters characterAtIndex:rnd]];
    }
    return result;
}

// ┌────────────────────────────────────────────────────────────────────────────────────────────────────
// │ return an array of professions
// └────────────────────────────────────────────────────────────────────────────────────────────────────
+ (NSArray *)professions {
    return [[professions allValues] sortedArrayUsingSelector:@selector(compare:)];
}

// ┌────────────────────────────────────────────────────────────────────────────────────────────────────
// │ return the text name of a profession given the ID
// └────────────────────────────────────────────────────────────────────────────────────────────────────
+ (NSString *)nameForProfession:(ProfessionID)professionID {
    return [professions objectForKey:[NSNumber numberWithInt:professionID]];
}

// ┌────────────────────────────────────────────────────────────────────────────────────────────────────
// │ return the ID of a profession given its text name
// └────────────────────────────────────────────────────────────────────────────────────────────────────
+ (ProfessionID)idForProfessionName:(NSString *)name {
    return [[[professions allKeysForObject:name] objectAtIndex:0] intValue];
}

// ┌────────────────────────────────────────────────────────────────────────────────────────────────────
// │ Write the user values into the db
// └────────────────────────────────────────────────────────────────────────────────────────────────────
+ (void)setUser:(User *)user {
    if (!handler.database) {
        [self open];
    }
    NSString *sqlString = [NSString stringWithFormat:@"INSERT INTO \"User\" (FirstName,LastName,Profession,HourlyRate) VALUES(\"%@\",\"%@\",\"%d\",\"%.02f\")", user.firstName, user.lastName, user.professionID, user.hourlyRate];
	const char *sql = [sqlString UTF8String];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(handler.database, sql, -1, &statement, NULL) == SQLITE_OK) {
		while (sqlite3_step(statement) != SQLITE_DONE) {}
	}
	sqlite3_finalize(statement);
}

// ┌────────────────────────────────────────────────────────────────────────────────────────────────────
// │ Update the user's values (profile) using the supplied values
// └────────────────────────────────────────────────────────────────────────────────────────────────────
+ (void)updateUser:(User *)user {
    if (!handler.database) {
        [self open];
    }
    NSString *sqlString = [NSString stringWithFormat:@"UPDATE \"User\" SET FirstName='%@',LastName='%@',Profession='%d',HourlyRate='%.02f'", user.firstName, user.lastName, user.professionID, user.hourlyRate];
	const char *sql = [sqlString UTF8String];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(handler.database, sql, -1, &statement, NULL) == SQLITE_OK) {
		while (sqlite3_step(statement) != SQLITE_DONE) {}
	}
	sqlite3_finalize(statement);
}

// ┌────────────────────────────────────────────────────────────────────────────────────────────────────
// │ return the user values (profile) from the db
// └────────────────────────────────────────────────────────────────────────────────────────────────────
+ (User *)user {
    if (!handler.database) {
        [self open];
    }
    NSString *sqlString = [NSString stringWithFormat:@"SELECT FirstName,LastName,Profession,HourlyRate FROM user"];
    const char *sql = [sqlString UTF8String];
    sqlite3_stmt *statement;
    User *user = nil;
    if (sqlite3_prepare_v2(handler.database, sql, -1, &statement, NULL) == SQLITE_OK) {
        if (sqlite3_step(statement) == SQLITE_ROW) {
            user = [[[User alloc] init] autorelease];
            user.firstName = [self stringForColumn:0 inStatement:statement];
            user.lastName = [self stringForColumn:1 inStatement:statement];
            user.professionID = sqlite3_column_int(statement, 2);
            user.hourlyRate = sqlite3_column_double(statement, 3);
        }
    }
    sqlite3_finalize(statement);
    return user;
}

// ┌────────────────────────────────────────────────────────────────────────────────────────────────────
// │ Add a new project into the DB
// └────────────────────────────────────────────────────────────────────────────────────────────────────
+ (void)addProject:(Project *)project {
    if (!handler.database) {
        [self open];
    }
    NSString *sqlString = [NSString stringWithFormat:@"INSERT INTO \"Projects\" (GUID,Name,Description,StartingDate,EndingDate,InitialQuote,Status,HoursTaken,AdditionalExpenses,Profitability) VALUES(\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%f\",\"%d\",\"%f\",\"%f\",\"%d\")", project.guid, project.name, project.description, [project.startingDate asDatabaseString], [project.endingDate asDatabaseString], project.initialQuote, project.status, project.hoursTaken, project.additionalExpenses, project.profitability];
	const char *sql = [sqlString UTF8String];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(handler.database, sql, -1, &statement, NULL) == SQLITE_OK) {
		while (sqlite3_step(statement) != SQLITE_DONE) {}
	}
	sqlite3_finalize(statement);
}

// ┌────────────────────────────────────────────────────────────────────────────────────────────────────
// │ Update the user's values (profile) using the supplied values
// └────────────────────────────────────────────────────────────────────────────────────────────────────
+ (void)updateProject:(Project *)project {
    if (!handler.database) {
        [self open];
    }
    NSString *sqlString = [NSString stringWithFormat:@"UPDATE \"Projects\" SET GUID='%@',Name='%@',Description='%@',StartingDate='%@',EndingDate='%@',InitialQuote='%f',Status='%d',HoursTaken='%f',AdditionalExpenses='%f',Profitability='%d' WHERE GUID='%@'", project.guid, project.name, project.description, [project.startingDate asDatabaseString], [project.endingDate asDatabaseString], project.initialQuote, project.status, project.hoursTaken, project.additionalExpenses, project.profitability, project.guid];
	const char *sql = [sqlString UTF8String];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(handler.database, sql, -1, &statement, NULL) == SQLITE_OK) {
		while (sqlite3_step(statement) != SQLITE_DONE) {}
	}
	sqlite3_finalize(statement);
}

+ (NSArray *)projectsWithStatus:(ProjectStatus)status profitability:(ProjectProfitability)profitability {
    if (!handler.database) {
        [self open];
    }
    NSString *sqlString = [NSString stringWithFormat:@"SELECT GUID FROM Projects WHERE Status='%d' AND Profitability='%d'", status, profitability];
	const char *sql = [sqlString UTF8String];
	sqlite3_stmt *statement;
    NSMutableArray *list = [NSMutableArray array];
	if (sqlite3_prepare_v2(handler.database, sql, -1, &statement, NULL) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
            [list addObject:[self stringForColumn:0 inStatement:statement]];
        }
    }
	sqlite3_finalize(statement);
    return list;
}

+ (Project *)projectForGUID:(NSString *)guid {
    if (!handler.database) {
        [self open];
    }
    NSString *sqlString = [NSString stringWithFormat:@"SELECT GUID,Name,Description,StartingDate,EndingDate,InitialQuote,Status,HoursTaken,AdditionalExpenses,Profitability FROM Projects WHERE GUID='%@'", guid];
	const char *sql = [sqlString UTF8String];
	sqlite3_stmt *statement;
    Project *project = nil;
	if (sqlite3_prepare_v2(handler.database, sql, -1, &statement, NULL) == SQLITE_OK) {
		if (sqlite3_step(statement) == SQLITE_ROW) {
            project = [[[Project alloc] init] autorelease];
            project.guid = [self stringForColumn:0 inStatement:statement];
            project.name = [self stringForColumn:1 inStatement:statement];
            project.description = [self stringForColumn:2 inStatement:statement];
            project.startingDate = [NSDate dateForDatabaseString:[self stringForColumn:3 inStatement:statement]];
            project.endingDate = [NSDate dateForDatabaseString:[self stringForColumn:4 inStatement:statement]];
            project.initialQuote = sqlite3_column_double(statement, 5);
            project.status = sqlite3_column_int(statement, 6);
            project.hoursTaken = sqlite3_column_double(statement, 7);
            project.additionalExpenses = sqlite3_column_double(statement, 8);
            project.profitability = sqlite3_column_int(statement, 9);
        }
    }
	sqlite3_finalize(statement);
    return project;
}

// ┌────────────────────────────────────────────────────────────────────────────────────────────────────
// │
// └────────────────────────────────────────────────────────────────────────────────────────────────────
- (id)init {
    self = [super init];
    if (self) {
        self.database = nil;
    }
    return self;
}

// ┌────────────────────────────────────────────────────────────────────────────────────────────────────
// │
// └────────────────────────────────────────────────────────────────────────────────────────────────────
- (void)dealloc {
    [Database close];
    [handler release];
    [super dealloc];
}

@end


@implementation User
@synthesize address1, address2, cell, city, country, firstName, hourlyRate, lastName, professionID, stateID, zip;

- (id)init {
    self = [super init];
    if (self) {
        self.professionID = ProfessionIDUndefined;
        self.stateID = StateIDUndefined;
    }
    return self;
}

- (void)dealloc {
    [firstName release];
    [lastName release];
    [cell release];
    [city release];
    [country release];
    [address2 release];
    [address1 release];
    [zip release];
    [super dealloc];
}

@end


@implementation Project
@synthesize name, description, guid, startingDate, endingDate, status, hoursTaken, additionalExpenses, initialQuote, profitability;

- (id)init {
    self = [super init];
    if (self) {
        self.startingDate = [NSDate date];  // Today
        self.status = ProjectStatusOngoing;
        self.guid = [Database GUID];
        self.profitability = ProjectProfitabilityUndefined;
    }
    return self;
}

- (void)dealloc {
    [name release];
    [description release];
    [guid release];
    [startingDate release];
    [endingDate release];
    [super dealloc];
}

@end

@implementation Calculation
@synthesize budgetIn, hoursIn, hoursOut, quoteOut, type;

@end


