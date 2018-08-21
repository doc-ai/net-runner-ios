//
//  AppDelegate.m
//  Net Runner
//
//  Created by Philip Dow on 7/26/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "AppDelegate.h"

#import "TIOModelBundleManager.h"
#import "NSArray+TIOExtensions.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    assert( sizeof(float_t) == 4 );
    
    // Load model bundles
    
    NSString *modelsPath = [[NSBundle mainBundle] pathForResource:@"models" ofType:nil];
    NSError *error;
    
    if ( ![TIOModelBundleManager.sharedManager loadModelBundlesAtPath:modelsPath error:&error] ) {
        NSLog(@"Unable to load model bundles at path %@", modelsPath);
    }
    
    // Register Defaults
    
    [NSUserDefaults.standardUserDefaults registerDefaults:[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"UserDefaults" ofType:@"plist"]]];
    
    // Kick off application
    
    UIViewController *vc;
    
    #ifdef HEADLESS
        NSLog(@"Running application in headless mode");
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Headless" bundle:[NSBundle mainBundle]];
        vc = [storyboard instantiateInitialViewController];
    #else
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        vc = [storyboard instantiateInitialViewController];
    #endif
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = vc;
    [self.window makeKeyAndVisible];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    
    UIApplication.sharedApplication.idleTimerDisabled = NO;
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    UIApplication.sharedApplication.idleTimerDisabled = YES;
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
