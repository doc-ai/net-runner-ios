//
//  AddModelTableViewController.m
//  Net Runner
//
//  Created by Philip Dow on 9/12/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "AddModelTableViewController.h"

@interface AddModelTableViewController ()

@end

@implementation AddModelTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAddModel:)];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

// MARK: - Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

// MARK: - Text Field Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

// MARK: - User Interaction

- (IBAction)cancelAddModel:(id)sender {
    [self resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)visitNetRunnerRepository:(id)sender {
    [UIApplication.sharedApplication openURL:[NSURL URLWithString:@"https://github.com/doc-ai/net-runner-ios"]];
}

- (IBAction)importModel:(id)sender {

}

@end
