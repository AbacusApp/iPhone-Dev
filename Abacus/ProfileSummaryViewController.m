//
//  ProfileSummaryViewController.m
//  Abacus
//
//  Created by Graham Savage on 5/3/13.
//  Copyright (c) 2013 Graham Savage. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ProfileSummaryViewController.h"
#import "SwipeyLabel.h"
#import "Persist.h"
#import "Database.h"

@interface ProfileSummaryViewController ()
@property   (nonatomic, retain)     IBOutlet    UIImageView     *photo;
@property   (nonatomic, retain)     IBOutlet    SwipeyLabel     *rate;
@property   (nonatomic, retain)     IBOutlet    UILabel         *name, *profession;

- (IBAction)revealMenu:(id)sender;
@end

@implementation ProfileSummaryViewController
@synthesize photo, rate, name, profession;


- (void)viewDidLoad {
    [super viewDidLoad];
    self.photo.layer.cornerRadius = self.photo.frame.size.width/2;
    self.photo.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.photo.layer.borderWidth = 3;
    
    double savedRate = [[Persist valueFor:@"HOURLY.RATE" secure:NO] doubleValue];
    if (savedRate) {
        self.rate.value = savedRate;
    } else {
        self.rate.value = 50;
        [Persist setValue:[NSString stringWithFormat:@"%0.0f", self.rate.value] forKey:@"HOURLY.RATE" secure:NO];
    }
    self.rate.delegate = self;
    User *user = [Database user];
    self.name.text = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
    self.profession.text = [Database nameForProfession:user.professionID];
}

- (void)viewWillAppear:(BOOL)animated {
    [self setProfilePhoto];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setProfilePhoto) name:@"PROFILE.PHOTO.CHANGED" object:nil];
}

- (void)setProfilePhoto {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docs = [paths objectAtIndex:0];
    NSString *path = [docs stringByAppendingPathComponent:[NSString stringWithFormat:@"profile.image.1"]];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    self.photo.image = image;
}

- (void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)revealMenu:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"REVEAL.MENU" object:nil];
}

- (void)swipeyLabel:(SwipeyLabel *)swipeyLabel didChange:(NSNumber *)value {
    [Persist setValue:[NSString stringWithFormat:@"%0.0f", [value doubleValue]] forKey:@"HOURLY.RATE" secure:NO];
}

- (void)dealloc {
    [photo release];
    [rate release];
    [name release];
    [profession release];
    [super dealloc];
}
@end
