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
#import "RadioButton.h"
#import "CompleteProjectViewController.h"
#import "UIViewController+Customizations.h"

@interface ProjectsViewController ()
@property   (nonatomic, retain)     IBOutlet    UILabel         *titleLabel;
@property   (nonatomic, retain)     IBOutlet    UITableView     *table;
@property   (nonatomic, retain)     IBOutlet    RadioButton     *allRadio, *profitableRadio, *unprofitableRadio;
@property   (nonatomic, retain)     NSArray     *projects;
@property   (nonatomic, retain)     Project     *selectedProject;

- (IBAction)revealMenu:(id)sender;
- (IBAction)changeList:(id)sender;
@end

@implementation ProjectsViewController
@synthesize projects, table, selectedProject, allRadio, profitableRadio, unprofitableRadio,titleLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self refreshList];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(projectCreated) name:@"PROJECT.CREATED" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(projectCompleted:) name:@"PROJECT.COMPLETED" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(undoProjectComplete:) name:@"UNDO.PROJECT.COMPLETE" object:nil];
}

- (void)projectCreated {
    [self refreshList];
}

// ┌────────────────────────────────────────────────────────────────────────────────────────────────────
// │ User taps the COMPLETE PROJECT button on the Complete project view
// └────────────────────────────────────────────────────────────────────────────────────────────────────
- (void)projectCompleted:(NSNotification *)note {
    [self performSelector:@selector(a) withObject:nil afterDelay:.4];
}

- (void)a {
    //Project *project = note.object;
    NSIndexPath *index = [table indexPathForSelectedRow];
    UITableViewCell *cell = [table cellForRowAtIndexPath:index];
    [UIView animateWithDuration:.20 animations:^{
        [cell viewWithTag:10].frame = CGRectMake(0, 0, cell.bounds.size.width, cell.bounds.size.height);
    } completion:^(BOOL finished) {
    }];
    [self refreshList];
}

// ┌────────────────────────────────────────────────────────────────────────────────────────────────────
// │ If the user taps the close button on the Complete Project view
// └────────────────────────────────────────────────────────────────────────────────────────────────────
- (void)undoProjectComplete:(NSNotification *)note {
    //Project *project = note.object;
    NSIndexPath *index = [table indexPathForSelectedRow];
    UITableViewCell *cell = [table cellForRowAtIndexPath:index];
    [UIView animateWithDuration:.20 animations:^{
        [cell viewWithTag:10].frame = CGRectMake(0, 0, cell.bounds.size.width, cell.bounds.size.height);
    } completion:^(BOOL finished) {
    }];
}

- (void)refreshList {
    if (allRadio.selected) {
        self.titleLabel.text = @"PROJECTS - Ongoing";
        self.projects = [Database projectsWithStatus:ProjectStatusOngoing profitability:ProjectProfitabilityUndefined];
    } else if (profitableRadio.selected) {
        self.titleLabel.text = @"PROJECTS - Profitable";
        self.projects = [Database projectsWithStatus:ProjectStatusCompleted profitability:ProjectProfitabilityProfitable];
    } else if (unprofitableRadio.selected) {
        self.titleLabel.text = @"PROJECTS - Unprofitable";
        self.projects = [Database projectsWithStatus:ProjectStatusCompleted profitability:ProjectProfitabilityUnProfitable];
    }
    [table reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (IBAction)changeList:(id)sender {
    [self refreshList];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return projects.count ? projects.count : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = @"ProjectCell";
    
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
		NSArray *array = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
		cell = (UITableViewCell *)[array objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UISwipeGestureRecognizer *right = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)] autorelease];
        right.direction = UISwipeGestureRecognizerDirectionRight;
        [cell addGestureRecognizer:right];
    }
    if (projects.count == 0) {
        UILabel *name = (UILabel *)[cell viewWithTag:1];
        name.text = nil;
        name = (UILabel *)[cell viewWithTag:3];
        name.text = nil;
        cell.accessoryType = UITableViewCellAccessoryNone;
        name = (UILabel *)[cell viewWithTag:2];
        if (allRadio.selected) {
            name.text = @"You have no projects in progress";
        } else if (profitableRadio.selected) {
            name.text = @"You have no profitable projects";
        } else if (unprofitableRadio.selected) {
            name.text = @"You have no unprofitable projects";
        }
        return cell;
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
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
    if (projects.count == 0) {
        return;
    }
    if (!allRadio.selected) {
        return;
    }
    UITableViewCell *cell = (UITableViewCell *)gestureRecognizer.view;
    NSIndexPath *indexPath = [table indexPathForCell:cell];
    NSString *projectID = [projects objectAtIndex:indexPath.row];
    self.selectedProject = [Database projectForGUID:projectID];
    [UIView animateWithDuration:.20 animations:^{
        [cell viewWithTag:10].frame = CGRectMake(cell.bounds.size.width, 0, cell.bounds.size.width, cell.bounds.size.height);
    } completion:^(BOOL finished) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [table selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        [Alerts showQuestionWithTitle:@"Complete Project" message:[NSString stringWithFormat:@"Is this project:\n\"%@\"\n complete?", self.selectedProject.name] cancel:@"No" ok:@"Yes" delegate:self tag:1];
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case 1: {
            NSIndexPath *index = [table indexPathForSelectedRow];
            UITableViewCell *cell = [table cellForRowAtIndexPath:index];
            if (buttonIndex == 0) {
                [UIView animateWithDuration:.20 animations:^{
                    [cell viewWithTag:10].frame = CGRectMake(0, 0, cell.bounds.size.width, cell.bounds.size.height);
                } completion:^(BOOL finished) {
                }];
            } else if (buttonIndex == 1) {
                CompleteProjectViewController *cp = [CompleteProjectViewController showModally];
                cp.project = selectedProject;
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
    [selectedProject release];
    [allRadio release];
    [profitableRadio release];
    [unprofitableRadio release];
    [titleLabel release];
    [super dealloc];
}
@end
