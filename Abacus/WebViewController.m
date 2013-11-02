//
//  WebViewController.m
//  Abacus
//
//  Created by Graham Savage on 5/6/13.
//  Copyright (c) 2013 Graham Savage. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()
@property   (nonatomic, retain)     IBOutlet    UILabel     *titleBar;
@property   (nonatomic, retain)     IBOutlet    UIWebView   *webView;

- (IBAction)close:(id)sender;
@end

@implementation WebViewController
@synthesize webView, titleBar, urlString;

- (void)viewDidLoad {
    [super viewDidLoad];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlString]]];
    self.titleBar.text = self.title;
}

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{}];
}
- (void)dealloc {
    [webView release];
    [titleBar release];
    [urlString release];
    [super dealloc];
}
@end
