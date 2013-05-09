//
//  ProjectsViewController.m
//  Abacus
//
//  Created by Graham Savage on 5/8/13.
//  Copyright (c) 2013 Graham Savage. All rights reserved.
//

#import "ProjectsViewController.h"
#import "Database.h"
#import "NSDate+Customizations.h"

@interface ProjectsViewController ()
@property   (nonatomic, retain)     NSArray     *projects;
- (IBAction)revealMenu:(id)sender;
@end

@implementation ProjectsViewController
@synthesize projects;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.projects = [Database projects];
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
    }
    Project *project = [Database projectForGUID:[projects objectAtIndex:indexPath.row]];
    UILabel *name = (UILabel *)[cell viewWithTag:1];
    name.text = project.name;
    UILabel *dates = (UILabel *)[cell viewWithTag:3];
    dates.text = [project.startingDate asDisplayString];
    return cell;
}

- (IBAction)revealMenu:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"REVEAL.MENU" object:nil];
}

- (void)dealloc {
    [projects release];
    [super dealloc];
}
@end
