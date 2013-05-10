//
//  ProjectsViewController.m
//  Abacus
//
//  Created by Graham Savage on 5/8/13.
//  Copyright (c) 2013 Graham Savage. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ProjectsViewController.h"
#import "Database.h"
#import "NSDate+Customizations.h"
#import "Alerts.h"

@interface ProjectsViewController ()
@property   (nonatomic, retain)     IBOutlet    UITableView     *table;
@property   (nonatomic, retain)     NSArray     *projects;
- (IBAction)revealMenu:(id)sender;
@end

@implementation ProjectsViewController
@synthesize projects, table;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.projects = [Database projects];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(projectCreated) name:@"PROJECT.CREATED" object:nil];
}

- (void)projectCreated {
    self.projects = [Database projects];
    [table reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return projects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = @"ProjectCell";
    
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
		NSArray *array = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
		cell = (UITableViewCell *)[array objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        UISwipeGestureRecognizer *right = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)] autorelease];
        right.direction = UISwipeGestureRecognizerDirectionRight;
        [cell addGestureRecognizer:right];
    }
    Project *project = [Database projectForGUID:[projects objectAtIndex:indexPath.row]];
    UILabel *name = (UILabel *)[cell viewWithTag:1];
    name.text = project.name;
    UILabel *quote = (UILabel *)[cell viewWithTag:2];
    quote.text = [NSString stringWithFormat:@"Price quoted: $%.02f", project.initialQuote];
    UILabel *dates = (UILabel *)[cell viewWithTag:3];
    dates.text = [project.startingDate asDisplayString];
    return cell;
}

- (void)swipe:(UISwipeGestureRecognizer *)gestureRecognizer {
    UITableViewCell *cell = (UITableViewCell *)gestureRecognizer.view;
    NSIndexPath *indexPath = [table indexPathForCell:cell];
    NSString *projectID = [projects objectAtIndex:indexPath.row];
    Project *project = [Database projectForGUID:projectID];
    [UIView animateWithDuration:.20 animations:^{
        [cell viewWithTag:10].layer.transform = CATransform3DMakeTranslation(cell.bounds.size.width, 0, 0);
    } completion:^(BOOL finished) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selected = YES;
        [Alerts showQuestionWithTitle:@"Complete Project" message:[NSString stringWithFormat:@"Are you sure you want to mark\n%@\nas completed?", project.name] cancel:@"Cancel" ok:@"Yes" delegate:self tag:1];
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case 1: {
            NSIndexPath *index = [table indexPathForSelectedRow];
            UITableViewCell *cell = [table cellForRowAtIndexPath:index];
            if (buttonIndex == 0) {
                [UIView animateWithDuration:.20 animations:^{
                    [cell viewWithTag:10].layer.transform = CATransform3DMakeTranslation(0, 0, 0);
                } completion:^(BOOL finished) {
                }];
            }
            break;
        }
    }
}

- (IBAction)revealMenu:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"REVEAL.MENU" object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [table release];
    [projects release];
    [super dealloc];
}
@end
