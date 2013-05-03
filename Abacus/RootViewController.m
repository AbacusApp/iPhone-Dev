//
//  ViewController.m
//  Abacus
//
//  Created by Graham Savage on 5/2/13.
//  Copyright (c) 2013 Graham Savage. All rights reserved.
//

#import <iAd/iAd.h>
#import "RootViewController.h"
#import "CalculatorViewController.h"
#import "ProfileSummaryViewController.h"
#import "RadioButton.h"
#import "MenuViewController.h"

@interface RootViewController () <ADBannerViewDelegate>
@property   (nonatomic, retain)     IBOutlet    UIView      *contentView;
@property   (nonatomic, retain)     IBOutlet    RadioButton *profileRadio, *calculatorRadio;
@property   (nonatomic, retain)     UITabBarController      *tabController;
@property   (nonatomic, retain)     MenuViewController      *menuController;

- (IBAction)tabTapped:(UIButton *)sender;
@end

@implementation RootViewController {
    ADBannerView *_bannerView;
}

@synthesize contentView, tabController, profileRadio, calculatorRadio, menuController;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:_bannerView];

    // Create and configure the tab bar controller
    self.tabController = [[[UITabBarController alloc] init] autorelease];
    self.tabController.view.frame = self.contentView.bounds;
    self.tabController.tabBar.hidden = YES;
    ProfileSummaryViewController *profile = [[[ProfileSummaryViewController alloc] initWithNibName:@"ProfileSummaryViewController" bundle:nil] autorelease];
    CalculatorViewController *calculator = [[[CalculatorViewController alloc] initWithNibName:@"CalculatorViewController" bundle:nil] autorelease];
    [self.tabController setViewControllers:[NSArray arrayWithObjects:profile, calculator, nil]];
    [self.contentView addSubview:self.tabController.view];
    
    // Need to bring the custom tab bar buttons on top of the tab bar controller
    [self.contentView bringSubviewToFront:self.profileRadio];
    [self.contentView bringSubviewToFront:self.calculatorRadio];
    
    // Add swipe gesture recognizers to both views on the tab bar controller - used to reveal the menu
    UISwipeGestureRecognizer *right = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(moveRight)] autorelease];
    right.direction = UISwipeGestureRecognizerDirectionRight;
    [profile.view addGestureRecognizer:right];
    //[calculator.view addGestureRecognizer:right];
    
    UISwipeGestureRecognizer *left = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(moveLeft)] autorelease];
    left.direction = UISwipeGestureRecognizerDirectionLeft;
    [profile.view addGestureRecognizer:left];
    //[calculator.view addGestureRecognizer:left];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // Create the menu and put it behind the rootview controller (me)
    if (!self.menuController) {
        self.menuController = [[[MenuViewController alloc] initWithNibName:@"MenuViewController" bundle:nil] autorelease];
        [self.view.superview insertSubview:self.menuController.view atIndex:0];
        self.menuController.view.frame = self.view.bounds;
    }
    [self layoutAnimated:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleReveal) name:@"REVEAL.MENU" object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    
}

- (void)toggleReveal {
    if (![self moveRight]) {
        [self moveLeft];
    }
}

- (BOOL)moveLeft {
    UIView *slider = self.view;
    if (slider.frame.origin.x != 0) {
        [UIView animateWithDuration:.25 animations:^{
            slider.frame = CGRectMake(0, slider.frame.origin.y, slider.frame.size.width, slider.frame.size.height);
        }];
        return YES;
    }
    return NO;
}

- (BOOL)moveRight {
    UIView *slider = self.view;
    if (slider.frame.origin.x == 0) {
        [UIView animateWithDuration:.25 animations:^{
            slider.frame = CGRectMake(self.view.frame.size.width - 44, slider.frame.origin.y, slider.frame.size.width, slider.frame.size.height);
        }];
        return YES;
    }
    return NO;
}

- (IBAction)tabTapped:(UIButton *)sender {
    [self.tabController setSelectedIndex:sender.tag];
}

- (void)dealloc {
    [contentView release];
    [tabController release];
    [profileRadio release];
    [calculatorRadio release];
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
