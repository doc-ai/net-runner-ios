//
//  EvaluateSelectModelsTableViewController.m
//  Net Runner
//
//  Created by Philip Dow on 7/17/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "EvaluateSelectModelsTableViewController.h"

#import "EvaluateModelTableViewCell.h"
#import "EvaluateSelectAlbumsTableViewController.h"
#import "ModelDetailsTableViewController.h"
#import "TIOModelBundleManager.h"
#import "ModelBundle.h"

static NSString * const kModelCellIdentifier = @"ModelCell";

@interface EvaluateSelectModelsTableViewController () <EvaluateModelTableViewCellActionTarget>

@property (nonatomic) NSSet<ModelBundle*> *selectedBundles;
@property (readonly) UIBarButtonItem *nextButton;

@end

// MARK: -

@implementation EvaluateSelectModelsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.selectedBundles = [[NSSet<ModelBundle*> alloc] init];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ( [segue.identifier isEqualToString:@"ModelDetailsSegue"] ) {
        ModelDetailsTableViewController *destination = (ModelDetailsTableViewController*)segue.destinationViewController;
        destination.bundle = TIOModelBundleManager.sharedManager.modelBundles[self.tableView.indexPathForSelectedRow.row];
    }
    else if ( [segue.identifier isEqualToString:@"SelectAlbumsSegue"] ) {
        EvaluateSelectAlbumsTableViewController *destination = (EvaluateSelectAlbumsTableViewController*)segue.destinationViewController;
        destination.data = @{
            @"bundles": self.selectedBundles.allObjects
        };
    }
}

- (void)setSelectedBundles:(NSSet<ModelBundle *> *)selectedBundles {
    _selectedBundles = selectedBundles;
    
    self.nextButton.enabled = _selectedBundles.count > 0;
}

- (UIBarButtonItem*)nextButton {
    return self.navigationItem.rightBarButtonItem;
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EvaluateModelTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kModelCellIdentifier forIndexPath:indexPath];
    ModelBundle *bundle = TIOModelBundleManager.sharedManager.modelBundles[indexPath.row];
    
    cell.titleLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];

    cell.accessoryType = [self.selectedBundles containsObject:bundle]
        ? UITableViewCellAccessoryCheckmark
        : UITableViewCellAccessoryNone;
    
    cell.actionTarget = self;
    cell.bundle = bundle;
    
    return cell;
}

// MARK: -

- (void)didSwitchBundle:(ModelBundle*)bundle toSelected:(BOOL)selected {
    if ( [self.selectedBundles containsObject:bundle] ) {
        [[self mutableSetValueForKey:@"selectedBundles"] removeObject:bundle];
    } else {
        [[self mutableSetValueForKey:@"selectedBundles"] addObject:bundle];
    }
}

// MARK: -

- (IBAction)cancelEvaluation:(id)sender {
    [self.delegate evaluateSelectModelsTableViewControllerDidCancel:self];
}

@end
