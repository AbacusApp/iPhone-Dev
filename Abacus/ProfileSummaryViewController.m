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

@interface ProfileSummaryViewController ()
@property   (nonatomic, retain)     IBOutlet    UIImageView     *photo;
@property   (nonatomic, retain)     IBOutlet    SwipeyLabel     *rate;

- (IBAction)revealMenu:(id)sender;
@end

@implementation ProfileSummaryViewController
@synthesize photo, rate;


- (void)viewDidLoad {
    [super viewDidLoad];
    self.photo.layer.cornerRadius = self.photo.frame.size.width/2;
    self.photo.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.photo.layer.borderWidth = 3;
    
    self.rate.value = 50;
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

- (void)dealloc {
    [photo release];
    [rate release];
    [super dealloc];
}
@end
