//
//  ModelDetailsJSONViewController.m
//  Net Runner
//
//  Created by Phil Dow on 9/27/18.
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

#import "ModelDetailsJSONViewController.h"

@import TensorIO;

@interface ModelDetailsJSONViewController ()

@end

@implementation ModelDetailsJSONViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:self.bundle.info options:NSJSONWritingPrettyPrinted error:nil];
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    self.textView.text = string;
    
    if ( @available(iOS 13.0, *) ) {
        self.view.backgroundColor = UIColor.systemBackgroundColor;
                
        if ( UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark ) {
            self.textView.textColor = [UIColor colorWithWhite:0.8 alpha:1.0];
        } else {
            self.textView.textColor = [UIColor colorWithWhite:0.2 alpha:1.0];
        }
    }
}

@end
