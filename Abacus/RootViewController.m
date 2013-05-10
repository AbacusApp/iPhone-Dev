//
//  ViewController.m
//  Abacus
//
//  Created by Graham Savage on 5/2/13.
//  Copyright (c) 2013 Graham Savage. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <iAd/iAd.h>
#import "RootViewController.h"
#import "CalculatorViewController.h"
#import "ProfileSummaryViewController.h"
#import "RadioButton.h"
#import "MenuViewController.h"
#import "UIImage+Retina4.h"
#import "ProjectsViewController.h"

@interface RootViewController () <ADBannerViewDelegate>
@property   (nonatomic, retain)     IBOutlet    UIView      *contentView;
@property   (nonatomic, retain)     IBOutlet    RadioButton *profileRadio, *calculatorRadio, *projectsRadio;
@property   (nonatomic, retain)     UITabBarController      *tabController;
@property   (nonatomic, retain)     MenuViewController      *menuController;

- (IBAction)tabTapped:(UIButton *)sender;
@end

@implementation RootViewController {
    ADBannerView *_bannerView;
}

@synthesize contentView, tabController, profileRadio, calculatorRadio, menuController, projectsRadio;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:_bannerView];

    // Create and configure the tab bar controller
    self.tabController = [[[UITabBarController alloc] init] autorelease];
    self.tabController.view.frame = self.contentView.bounds;
    self.tabController.tabBar.hidden = YES;
    ProfileSummaryViewController *profile = [[[ProfileSummaryViewController alloc] initWithNibName:@"ProfileSummaryViewController" bundle:nil] autorelease];
    CalculatorViewController *calculator = nil;
    if ([UIImage isRetina4]) {
        calculator = [[[CalculatorViewController alloc] initWithNibName:@"CalculatorViewController-568h@2x" bundle:nil] autorelease];
    } else {
        calculator = [[[CalculatorViewController alloc] initWithNibName:@"CalculatorViewController" bundle:nil] autorelease];
    }
    ProjectsViewController *projects = [[[ProjectsViewController alloc] initWithNibName:@"ProjectsViewController" bundle:nil] autorelease];
    [self.tabController setViewControllers:[NSArray arrayWithObjects:profile, calculator, projects, nil]];
    [self.contentView addSubview:self.tabController.view];
    
    // Need to bring the custom tab bar buttons on top of the tab bar controller
    [self.contentView bringSubviewToFront:self.profileRadio];
    [self.contentView bringSubviewToFront:self.calculatorRadio];
    [self.contentView bringSubviewToFront:self.projectsRadio];
    
    // Add swipe gesture recognizer to both views on the tab bar controller - used to reveal the menu
    UISwipeGestureRecognizer *right = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(moveRight)] autorelease];
    right.direction = UISwipeGestureRecognizerDirectionRight;
    [profile.view addGestureRecognizer:right];
    right = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(moveRight)] autorelease];
    right.direction = UISwipeGestureRecognizerDirectionRight;
    [calculator.view addGestureRecognizer:right];
    right = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(moveRight)] autorelease];
    right.direction = UISwipeGestureRecognizerDirectionRight;
    [projects.view addGestureRecognizer:right];

    // Enable the drop-shadow that will be visible on left side
    self.view.layer.shadowOpacity = 0.6;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleReveal) name:@"REVEAL.MENU" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToProjectsTab) name:@"PROJECT.CREATED" object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // Create the menu and put it behind the rootview controller (me)
    if (!self.menuController) {
        self.menuController = [[[MenuViewController alloc] initWithNibName:@"MenuViewController" bundle:nil] autorelease];
        [self.view.superview insertSubview:self.menuController.view atIndex:0];
        self.menuController.view.frame = self.view.bounds;
        [self layoutAnimated:NO];
    }
}

- (void)toggleReveal {
    if (![self moveRight]) {
        [self moveLeft];
    }
}

- (BOOL)moveLeft {
    if (self.view.frame.origin.x != 0) {
        UIView *closeButton = [self.view viewWithTag:123];
        [closeButton removeFromSuperview];
        [UIView animateWithDuration:.2 animations:^{
            self.view.frame = CGRectMake(0, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
        } completion:^(BOOL finished) {
        }];
        return YES;
    }
    return NO;
}

- (BOOL)moveRight {
    if (self.view.frame.origin.x == 0) {
        [UIView animateWithDuration:.2 animations:^{
            self.view.frame = CGRectMake(self.view.frame.size.width - 44, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
        } completion:^(BOOL finished) {
            UIButton *closeButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, self.view.bounds.size.height)] autorelease];
            [closeButton addTarget:self action:@selector(moveLeft) forControlEvents:UIControlEventTouchUpInside];
            closeButton.tag = 123;
            [self.view addSubview:closeButton];
        }];
        return YES;
    }
    return NO;
}

- (IBAction)tabTapped:(UIButton *)sender {
    [self.tabController setSelectedIndex:sender.tag];
}

- (void)goToProjectsTab {
    [self.tabController setSelectedIndex:2];
    projectsRadio.selected = YES;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [contentView release];
    [tabController release];
    [profileRadio release];
    [calculatorRadio release];
    [projectsRadio release];
    [menuController release];
    [super dealloc];
}


/*
 Ad methods from here on...
 */
- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle {
    self = [super initWithNibName:nibName bundle:nibBundle];
    if (self) {
        // On iOS 6 ADBannerView introduces a new initializer, use it when available.
        if ([ADBannerView instancesRespondToSelector:@selector(initWithAdType:)]) {
            _bannerView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
        } else {
            _bannerView = [[ADBannerView alloc] init];
        }
        _bannerView.delegate = self;
    }
    return self;
}

- (void)layoutAnimated:(BOOL)animated {
    // As of iOS 6.0, the banner will automatically resize itself based on its width.
    // To support iOS 5.0 however, we continue to set the currentContentSizeIdentifier appropriately.
    CGRect contentFrame = self.view.bounds;
    if (contentFrame.size.width < contentFrame.size.height) {
        _bannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
    } else {
        _bannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierLandscape;
    }
    
    CGRect bannerFrame = _bannerView.frame;
    if (_bannerView.bannerLoaded) {
        contentFrame.origin.y += _bannerView.frame.size.height;
        contentFrame.size.height -= _bannerView.frame.size.height;
        bannerFrame.origin.y = 0;
    } else {
        bannerFrame.origin.y = -bannerFrame.size.height;
    }
    
    [UIView animateWithDuration:animated ? 0.25 : 0.0 animations:^{
        contentView.frame = contentFrame;
        [contentView layoutIfNeeded];
        _bannerView.frame = bannerFrame;
    }];
}

- (void)viewDidLayoutSubviews {
    [self layoutAnimated:[UIView areAnimationsEnabled]];
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
    [self layoutAnimated:YES];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    [self layoutAnimated:YES];
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave {
    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner {
}

@end
