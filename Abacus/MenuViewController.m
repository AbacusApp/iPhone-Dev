//
//  MenuViewController.m
//  Abacus
//
//  Created by Graham Savage on 5/3/13.
//  Copyright (c) 2013 Graham Savage. All rights reserved.
//

#import "MenuViewController.h"
#import "EditProfileViewController.h"
#import "WebViewController.h"

@interface MenuViewController ()
@property   (nonatomic, retain)     IBOutlet    UILabel     *version;
@end

@implementation MenuViewController
@synthesize version;

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *v = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    self.version.text = [NSString stringWithFormat:@"version %@", v];

     UISwipeGestureRecognizer *left = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(closeMenu)] autorelease];
     left.direction = UISwipeGestureRecognizerDirectionLeft;
     [self.view addGestureRecognizer:left];
}

- (IBAction)closeMenu {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"REVEAL.MENU" object:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = @"MenuCell";
    
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
		NSArray *array = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
		cell = (UITableViewCell *)[array objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.font = [UIFont fontWithName:@"Avenir-Light" size:15];
        cell.detailTextLabel.textColor = [UIColor colorWithWhite:.596 alpha:1];
    }
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Edit Profile";
            cell.imageView.image = [UIImage imageNamed:@"menu.icon.editProfile.png"];
            break;
        case 1:
            cell.textLabel.text = @"Links and Resources";
            cell.imageView.image = [UIImage imageNamed:@"menu.icon.links.png"];
            break;
        case 2:
            cell.textLabel.text = @"Share this App";
            cell.imageView.image = [UIImage imageNamed:@"menu.icon.share.png"];
            break;
        case 3:
            cell.textLabel.text = @"FAQ";
            cell.imageView.image = [UIImage imageNamed:@"menu.icon.faq.png"];
            break;
        case 4:
            cell.textLabel.text = @"About Abacus";
            cell.imageView.image = [UIImage imageNamed:@"menu.icon.about.png"];
            break;
        case 5:
            cell.textLabel.text = @"Suppport";
            cell.imageView.image = [UIImage imageNamed:@"menu.icon.support.png"];
            break;
    }
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0: {
            [EditProfileViewController show];
        }
            break;
        case 1: {
            [self closeMenu];
            WebViewController *webview = [[[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil] autorelease];
            webview.title = @"Abacus - Links & Resources";
            webview.urlString = @"http://resources.freelanceabacus.com";
            webview.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            [self.view.window.rootViewController presentModalViewController:webview animated:YES];
        }
            break;
        case 2:
            break;
        case 3: {
            [self closeMenu];
            WebViewController *webview = [[[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil] autorelease];
            webview.title = @"Abacus - FAQ";
            webview.urlString = @"http://faq.freelanceabacus.com";
            webview.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            [self.view.window.rootViewController presentModalViewController:webview animated:YES];
        }
            break;
        case 4: {
            [self closeMenu];
            WebViewController *webview = [[[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil] autorelease];
            webview.title = @"Abacus - Links & Resources";
            webview.urlString = @"http://www.google.com";
            webview.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            [self.view.window.rootViewController presentModalViewController:webview animated:YES];
        }
            break;
        case 5: {
            [self closeMenu];
            WebViewController *webview = [[[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil] autorelease];
            webview.title = @"Abacus - Support";
            webview.urlString = @"http://support.freelanceabacus.com";
            webview.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            [self.view.window.rootViewController presentModalViewController:webview animated:YES];
        }
            break;
    }
}

- (void)dealloc {
    [version release];
    [super dealloc];
}

@end
