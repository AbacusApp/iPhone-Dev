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
    ProfessionIDActorActress = 1,
    ProfessionIDAnimator = 2,
    ProfessionIDConceptArtist = 3,
    ProfessionIDCopywriterAdvertising = 4,
    ProfessionIDCopywriterCreative = 5,
    ProfessionIDCreativeInstructor = 6,
    ProfessionIDDeveloperAndroid = 7,
    ProfessionIDDeveloperBlackberry = 8,
    ProfessionIDDeveloperiOS = 9,
    ProfessionIDDeveloperMacPC = 10,
    ProfessionIDDeveloperWeb = 11,
    ProfessionIDDeveloperWindowsPhone = 12,
    ProfessionIDEventPlanner = 13,
    ProfessionIDFashionDesigner = 14,
    ProfessionIDFilmDirector = 15,
    ProfessionIDFilmaker = 16,
    ProfessionIDGraphicDesigner = 17,
    ProfessionIDIllustratorDigital = 18,
    ProfessionIDIllustratorTraditional = 19,
    ProfessionIDMerchandiser = 20,
    ProfessionIDModelPhotography = 21,
    ProfessionIDModelVideo = 22,
    ProfessionIDMotionGraphicsArtist = 23,
    ProfessionIDMusician = 24,
    ProfessionIDPhotographer = 25,
    ProfessionIDProducer = 26,
    ProfessionIDUIUXDesigner = 27,
    ProfessionIDVideoGameDesigner = 28,
    ProfessionIDVideoProductionArtist = 29,
    ProfessionIDVirtualAssistant = 30,
    ProfessionIDWebDesigner = 31,
    ProfessionIDOther = 1000,
} ProfessionID;

typedef enum {
    StateIDUndefined = 0,
    StateIDAlabama = 1,
    StateIDAlaska = 2,
} StateID;

typedef enum {
    ProjectStatusUndefined = 0,
    ProjectStatusOngoing = 1,
    ProjectStatusCompleted = 2,
    ProjectStatusCancelled = 3,
} ProjectStatus;

typedef enum {
    ProjectProfitabilityUndefined = 0,
    ProjectProfitabilityProfitable = 1,
    ProjectProfitabilityUnProfitable = 2,
} ProjectProfitability;

@interface User : NSObject
@property   (nonatomic, retain)     NSString        *firstName, *lastName, *address1, *address2, *city, *zip, *cell, *country;
@property   (nonatomic, assign)     double          hourlyRate;
@property   (nonatomic, assign)     ProfessionID    professionID;
@property   (nonatomic, assign)     StateID         stateID;
@end


@interface Project : NSObject
@property   (nonatomic, retain)     NSString                *guid, *name, *description;
@property   (nonatomic, assign)     double                  initialQuote, hoursTaken, additionalExpenses;
@property   (nonatomic, assign)     ProjectStatus           status;
@property   (nonatomic, retain)     NSDate                  *startingDate, *endingDate;
@property   (nonatomic, assign)     ProjectProfitability    profitability;
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
+ (void)addProject:(Project *)project;
+ (void)updateProject:(Project *)project;
+ (NSArray *)projectsWithStatus:(ProjectStatus)status profitability:(ProjectProfitability)profitability;
+ (Project *)projectForGUID:(NSString *)guid;
+ (User *)user;
@end
