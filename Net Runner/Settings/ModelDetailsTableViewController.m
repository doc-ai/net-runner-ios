//
//  ModelDetailsTableViewController.m
//  Net Runner
//
//  Created by Philip Dow on 7/10/18.
//  Copyright © 2018 doc.ai (http://doc.ai)
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "ModelDetailsTableViewController.h"

#import "TIOModelBundle.h"
#import "TIOModel.h"

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
