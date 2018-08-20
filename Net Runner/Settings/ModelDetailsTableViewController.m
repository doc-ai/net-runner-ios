//
//  ModelDetailsTableViewController.m
//  Net Runner
//
//  Created by Philip Dow on 7/10/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "ModelDetailsTableViewController.h"

#import "TIOModelBundle.h"
#import "Model.h"

@interface ModelDetailsTableViewController ()

@end

@implementation ModelDetailsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

- (void)viewWillAppear:(BOOL)animated {
    self.title = self.bundle.name;
    self.nameLabel.text = self.bundle.name;
    self.authorLabel.text = self.bundle.author;
    self.descriptionLabel.text = self.bundle.details;
    self.licenseLabel.text = self.bundle.license;
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
    case 0:
        return NSLocalizedString(@"Name", @"Model name section heading");
    case 1:
        return NSLocalizedString(@"Author", @"Model authors section heading");
    case 2:
        return NSLocalizedString(@"Description", @"Model description section heading");
    case 3:
        return NSLocalizedString(@"License", @"Model license section heading");
    default:
        return @"";
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
