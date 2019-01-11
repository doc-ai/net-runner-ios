//
//  ImageSettingsTableViewController.m
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

#import "ImageSettingsTableViewController.h"
#import "UserDefaults.h"

@interface ImageSettingsTableViewController ()

@end

@implementation ImageSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.rowHeight = 44;
    
    self.showInputBuffersSwitch.on = [NSUserDefaults.standardUserDefaults boolForKey:kPrefsShowInputBuffers];
    self.showInputBuffersAlphaSwitch.on = [NSUserDefaults.standardUserDefaults boolForKey:kPrefsShowInputBufferAlpha];
}

// MARK: -

- (IBAction)toggleShowInputBuffers {
    [NSUserDefaults.standardUserDefaults setBool:![NSUserDefaults.standardUserDefaults boolForKey:kPrefsShowInputBuffers] forKey:kPrefsShowInputBuffers];
}

- (IBAction)toggleShowInputBuffersAlpha:(id)sender {
    [NSUserDefaults.standardUserDefaults setBool:![NSUserDefaults.standardUserDefaults boolForKey:kPrefsShowInputBufferAlpha] forKey:kPrefsShowInputBufferAlpha];
}

@end
