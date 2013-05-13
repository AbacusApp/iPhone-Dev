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
    StateIDArizona = 3,
    StateIDArkansas = 4,
    StateIDCalifornia = 5,
    StateIDColorado = 6,
    StateIDConnecticut = 7,
    StateIDDelaware = 8,
    StateIDDistrictofColumbia = 9,
    StateIDFlorida = 10,
    StateIDGeorgia = 11,
    StateIDHawaii = 12,
    StateIDIdaho = 13,
    StateIDIllinois = 14,
    StateIDIndiana = 15,
    StateIDIowa = 16,
    StateIDKansas = 17,
    StateIDKentucky = 18,
    StateIDLouisiana = 19,
    StateIDMaine = 20,
	StateIDMaryland = 21,
    StateIDMassachusetts = 22,
    StateIDMichigan = 23,
    StateIDMinnesota = 24,
    StateIDMississippi = 25,
    StateIDMissouri = 26,
    StateIDMontana = 27,
    StateIDNebraska = 28,
    StateIDNevada = 29,
    StateIDNewHampshire = 30,
    StateIDNewJersey = 31,
    StateIDNewMexico  =32,
    StateIDNewYork = 33,
    StateIDNorthCarolina = 34,
    StateIDNorthDakota = 35,
    StateIDOhio = 36,
    StateIDOklahoma = 37,
    StateIDOregon = 38,
    StateIDPennsylvania = 39,
    StateIDRhodeIsland = 40,
	StateIDSouthCarolina = 41,
    StateIDSouthDakota = 42,
    StateIDTennessee = 43,
    StateIDTexas = 44,
    StateIDUtah = 45,
    StateIDVermont = 46,
    StateIDVirginia = 47,
    StateIDWashington = 48,
    StateIDWestVirginia = 49,
    StateIDWisconsin = 50,
    StateIDWyoming = 51
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

typedef enum {
    CalculationTypeUndefined = 0,
    CalculationTypeByHours = 1,
    CalculationTypeByBudget = 2,
} CalculationType;

@interface Profile : NSObject
@property   (nonatomic, retain)     NSString        *guid, *firstName, *lastName, *address1, *address2, *city, *zip, *cell, *country;
@property   (nonatomic, assign)     double          hourlyRate;
@property   (nonatomic, assign)     ProfessionID    professionID;
@property   (nonatomic, assign)     StateID         stateID;
@end


@interface Project : NSObject
@property   (nonatomic, retain)     NSString                *guid, *name, *description, *profileGUID;
@property   (nonatomic, assign)     double                  initialQuote, hoursTaken, additionalExpenses, hourlyRate;
@property   (nonatomic, assign)     ProjectStatus           status;
@property   (nonatomic, retain)     NSDate                  *startingDate, *endingDate;
@property   (nonatomic, assign)     ProjectProfitability    profitability;
@end

@interface Calculation : NSObject
@property   (nonatomic, assign)     CalculationType         type;
@property   (nonatomic, assign)     double                  hoursIn, quoteOut, budgetIn, hoursOut;
@end

@interface Database : NSObject
@property (nonatomic, assign)	sqlite3		*database;

+ (BOOL)dbExists;
+ (void)makeDB;
+ (NSArray *)professions;
+ (NSArray *)states;
+ (NSString *)nameForProfession:(ProfessionID)professionID;
+ (NSString *)nameForState:(StateID)stateID;
+ (ProfessionID)idForProfessionName:(NSString *)name;
+ (StateID)idForStateName:(NSString *)name;
+ (void)addProfile:(Profile *)user;
+ (void)updateProfile:(Profile *)user;
+ (void)addProject:(Project *)project;
+ (void)updateProject:(Project *)project;
+ (NSArray *)projectsWithStatus:(ProjectStatus)status profitability:(ProjectProfitability)profitability;
+ (Project *)projectForGUID:(NSString *)guid;
+ (Profile *)profile;
@end
