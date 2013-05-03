//
//  ProfileSummaryViewController.m
//  Abacus
//
//  Created by Graham Savage on 5/3/13.
//  Copyright (c) 2013 Graham Savage. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ProfileSummaryViewController.h"

@interface ProfileSummaryViewController ()
@property   (nonatomic, retain)     IBOutlet    UIImageView     *photo;

- (IBAction)revealMenu:(id)sender;
@end

@implementation ProfileSummaryViewController
@synthesize photo;


- (void)viewDidLoad {
    [super viewDidLoad];
    self.photo.layer.cornerRadius = self.photo.frame.size.width/2;
    self.photo.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.photo.layer.borderWidth = 2;
}

- (IBAction)revealMenu:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"REVEAL.MENU" object:nil];
}

- (void)dealloc {
    [photo release];
    [super dealloc];
}
@end
