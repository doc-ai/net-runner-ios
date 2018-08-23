//
//  HeadlessViewController.m
//  Net Runner
//
//  Created by Philip Dow on 7/19/18.
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

#import "HeadlessViewController.h"

#import "HeadlessTestBundleRunner.h"
#import "HeadlessTestBundleManager.h"
#import "HeadlessTestBundle.h"
#import "EvaluationResultsActivityItemProvider.h"

@import TensorIO;

@interface HeadlessViewController ()

@property (readonly) UIBarButtonItem *shareButton;

@property NSArray<HeadlessTestBundle*> *testBundles;
@property NSArray<NSDictionary*> *results;
@property NSArray<NSDictionary*> *summary;

@end

@implementation HeadlessViewController {
    dispatch_queue_t _evaluatorQueue;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _evaluatorQueue = dispatch_queue_create("headless_evaluator_queue", NULL);
    
    self.shareButton.enabled = NO;
    self.resultsLabel.hidden = YES;
    self.summaryLabel.hidden = YES;
    
    // Load test bundles
    
    NSString *headlessPath = [[NSBundle mainBundle] pathForResource:@"headless" ofType:nil];
    NSError *error;
    
    if ( ![[HeadlessTestBundleManager sharedManager] loadTestBundlesAtPath:headlessPath error:&error] ) {
        NSLog(@"Unable to load headless tests at path %@", headlessPath);
        return;
    } else {
        self.testBundles = [HeadlessTestBundleManager sharedManager].testBundles;
        NSLog(@"Loaded %tu test bundles", self.testBundles.count);
    }
    
    // Kick it off
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self evaluateTestBundles];
    });
}

- (void)evaluateTestBundles {
    dispatch_async(_evaluatorQueue, ^{
        
        NSMutableArray<NSDictionary*> *results = [[NSMutableArray<NSDictionary*> alloc] init];
        NSMutableArray<NSDictionary*> *summary = [[NSMutableArray<NSDictionary*> alloc] init];
        
        for ( HeadlessTestBundle *testBundle in self.testBundles ) {
            @autoreleasepool {
                HeadlessTestBundleRunner *runner = [[HeadlessTestBundleRunner alloc] initWithTestBundle:testBundle];
                [runner evaluate];
                
                [results addObjectsFromArray:runner.results];
                
                for ( NSDictionary *model in runner.summary ) {
                    NSMutableDictionary *copy = [model mutableCopy];
                    copy[@"test_bundle"] = testBundle.identifier;
                    [summary addObject:copy];
                }
                
                // summary[testBundle.identifier] = runner.summary;
            }
        }
        
        self.results = results;
        self.summary = summary;
        
        NSLog(@"Completed running test bundles, %tu total results", results.count);
        
        // Do something with results and summary statistics, e.g. upload them to a server
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            self.statusLabel.text = @"Completed evaluation";
            [self.activityIndicator stopAnimating];
            
            self.resultsLabel.text = [summary description];
            self.shareButton.enabled = YES;
            self.resultsLabel.hidden = NO;
            self.summaryLabel.hidden = NO;
        });
    });
}

- (UIBarButtonItem*)shareButton {
    return self.navigationItem.rightBarButtonItem;
}

- (IBAction)shareResults:(id)sender {
    NSDictionary *evaluation = @{
        @"summary": self.summary,
        @"results": self.results
    };
    
    EvaluationResultsActivityItemProvider *provider = [[EvaluationResultsActivityItemProvider alloc] initWithResults:evaluation];
    UIActivityViewController *vc = [[UIActivityViewController alloc] initWithActivityItems:@[provider] applicationActivities:nil];
    
    [self presentViewController:vc animated:YES completion:nil];
}

@end
