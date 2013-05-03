//
//  MenuViewController.m
//  Abacus
//
//  Created by Graham Savage on 5/3/13.
//  Copyright (c) 2013 Graham Savage. All rights reserved.
//

#import "MenuViewController.h"

@interface MenuViewController ()

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
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
            cell.textLabel.text = @"Links and Resources";
            cell.imageView.image = [UIImage imageNamed:@"menu.icon.links.png"];
            break;
        case 1:
            cell.textLabel.text = @"Share this App";
            cell.imageView.image = [UIImage imageNamed:@"menu.icon.share.png"];
            break;
        case 2:
            cell.textLabel.text = @"FAQ";
            cell.imageView.image = [UIImage imageNamed:@"menu.icon.faq.png"];
            break;
        case 3:
            cell.textLabel.text = @"About Abacus";
            cell.imageView.image = [UIImage imageNamed:@"menu.icon.about.png"];
            break;
    }
	return cell;
}

- (void)dealloc {
    
    [super dealloc];
}

@end
