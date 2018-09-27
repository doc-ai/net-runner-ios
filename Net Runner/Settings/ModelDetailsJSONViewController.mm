//
//  ModelDetailsJSONViewController.m
//  Net Runner
//
//  Created by Phil Dow on 9/27/18.
//  Copyright © 2018 doc.ai. All rights reserved.
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
}

@end
