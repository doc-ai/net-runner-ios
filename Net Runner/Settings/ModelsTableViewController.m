//
//  ModelsTableViewController.
//  Net Runner
//
//  Created by Philip Dow on 7/16/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "ModelsTableViewController.h"

#import "ModelDetailsTableViewController.h"
#import "TIOModelBundleManager.h"
#import "TIOModelBundle.h"
#import "Model.h"

@interface ModelsTableViewController ()

@end

@implementation ModelsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ( [segue.identifier isEqualToString:@"ModelDetailsSegue"] ) {
        ModelDetailsTableViewController *destination = (ModelDetailsTableViewController*)segue.destinationViewController;
        destination.bundle = TIOModelBundleManager.sharedManager.modelBundles[((NSIndexPath*)sender).row];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return TIOModelBundleManager.sharedManager.modelBundles.count;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
    case 0:
        return @"TensorFlow Lite Models";
    default:
        return @"";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ModelCell" forIndexPath:indexPath];
    TIOModelBundle *bundle = [TIOModelBundleManager.sharedManager.modelBundles objectAtIndex:indexPath.row];
    
    cell.textLabel.text = bundle.name;
    cell.accessoryType = UITableViewCellAccessoryDetailButton;
    
    cell.textLabel.font = self.selectedBundle == bundle
        ? [UIFont boldSystemFontOfSize:[UIFont systemFontSize]]
        : [UIFont systemFontOfSize:[UIFont systemFontSize]];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self deselectModelRowsExceptRowAtIndexPath:indexPath];
    
    [tableView cellForRowAtIndexPath:indexPath].textLabel.font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
    self.selectedBundle = [TIOModelBundleManager.sharedManager.modelBundles objectAtIndex:indexPath.row];
    
    [self.delegate modelTableViewController:self didSelectBundle:self.selectedBundle];
}

- (void)deselectModelRowsExceptRowAtIndexPath:(NSIndexPath *)indexPath {
    const NSInteger modelSection = 0;
    
    for (NSInteger row = 0; row < [self.tableView numberOfRowsInSection:modelSection]; row++) {
        if (row == indexPath.row) {
            continue;
        }
        NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:modelSection];
        [self.tableView cellForRowAtIndexPath:path].textLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"ModelDetailsSegue" sender:indexPath];
}

@end
