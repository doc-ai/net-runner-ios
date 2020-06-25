//
//  AppDelegate.m
//  Net Runner
//
//  Created by Philip Dow on 7/26/18.
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
//  BUILD STEPS
//  TODO: Remove models we don't want to appear in the app store

#import "AppDelegate.h"

#import "ModelManager.h"
#import "UserDefaults.h"

@import SVProgressHUD;
@import EDSemver;
@import TensorIO;

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    assert( sizeof(float_t) == 4 );
    
    // Move model bundles into Documents/models/ directory and then load them
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *modelsPath = ModelManager.sharedManager.modelsPath;
    NSError *error;
    
    // For Build 7, in case user installed previous models with build 6, clean the models directory
    
    if ( ![NSUserDefaults.standardUserDefaults boolForKey:kPrefsBuild7CleanedModelsDir] ) {
        [NSUserDefaults.standardUserDefaults setBool:YES forKey:kPrefsBuild7CleanedModelsDir];
        if ( [fileManager fileExistsAtPath:modelsPath] ) {
            NSError *removeError;
            if ( ![fileManager removeItemAtPath:modelsPath error:&removeError] ) {
                NSLog(@"Error deleting file at path %@, error %@", modelsPath, removeError);
            }
        }
    }
    
    // Copy models from app bundle to documents irectory
    
    if (![fileManager fileExistsAtPath:modelsPath]) {
        NSLog(@"Loading packaged models into modelsPath: %@", modelsPath);
        BOOL copySuccess = [fileManager copyItemAtPath:ModelManager.sharedManager.initialModelsPath toPath:modelsPath error:&error];
        if (!copySuccess) {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    } else {
        NSLog(@"File/directory already exists at modelsPath: %@", modelsPath);
    }
    
    // Perform any data or model migrations
    
    [self performMigrations];
    
    // Load models
    
    if ( ![TIOModelBundleManager.sharedManager loadModelBundlesAtPath:modelsPath error:&error] ) {
        NSLog(@"Unable to load model bundles at path %@", modelsPath);
    }
    
    // Register Defaults
    
    [NSUserDefaults.standardUserDefaults registerDefaults:[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"UserDefaults" ofType:@"plist"]]];
    
    // Global Appearance
    
    [self updateGlobalAppearance];
    
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setMinimumDismissTimeInterval:2.0];
    
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
    
    // Update global appearance in case dark/light mode has changed
    
    [self updateGlobalAppearance];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    UIApplication.sharedApplication.idleTimerDisabled = YES;
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

// MARK: - Global Appearance

- (void)updateGlobalAppearance {
    // [UIColor colorWithWhite:0.2 alpha:1.0]
    // [UIColor colorWithWhite:0.8 alpha:1.0]
    
    // UIColor.lightTextColor
    // UIColor.darkTextColor
    
    [[UILabel appearanceWhenContainedInInstancesOfClasses:@[UITableView.class]] setTextColor:[UIColor colorWithWhite:0.2 alpha:1.0]];
    [[UIImageView appearanceWhenContainedInInstancesOfClasses:@[UITableView.class]] setTintColor:[UIColor colorWithWhite:0.2 alpha:1.0]];
    
    if ( @available(iOS 13.0, *) ) {
        if ( UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark ) {
            [[UILabel appearanceWhenContainedInInstancesOfClasses:@[UITableView.class]] setTextColor:[UIColor colorWithWhite:0.8 alpha:1.0]];
            [[UIImageView appearanceWhenContainedInInstancesOfClasses:@[UITableView.class]] setTintColor:[UIColor colorWithWhite:0.8 alpha:1.0]];
        }
    }
}

// MARK: - Migrations

- (void)performMigrations {
    NSString *currentVersionString = NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"];
    NSString *lastVersionString = [NSUserDefaults.standardUserDefaults stringForKey:kPrefsVersionLast];
    if (!lastVersionString) { lastVersionString = @"0.0.0"; }
    
    EDSemver *lastVersion = [EDSemver semverWithString:lastVersionString];
    
    EDSemver *vMajor2Minor0Patch3 = [EDSemver semverWithString:@"2.0.3"];
    
    if ([lastVersion compare:vMajor2Minor0Patch3] == NSOrderedAscending) {
        NSLog(@"Performing 2.0.3 Migration (TensorIO 0.6.1)");
        [self performMajor2Minor0Patch3Migration];
    }
    
    [NSUserDefaults.standardUserDefaults setObject:currentVersionString forKey:kPrefsVersionLast];
}

- (void)performMajor2Minor0Patch3Migration {
    
    // Rename .tfbundle extensions to .tiobundle
    
    NSString *modelsPath = ModelManager.sharedManager.modelsPath;
    NSFileManager *fm = NSFileManager.defaultManager;
    
    if (![fm fileExistsAtPath:modelsPath]) {
        return;
    }
    
    NSArray<NSString*> *contents = [fm contentsOfDirectoryAtPath:modelsPath error:nil];
    for (NSString *filename in contents) {
        if (![filename.pathExtension isEqualToString:TIOTFModelBundleExtension]) {
            continue;
        }
        
        NSString *dstFilename = [[filename stringByDeletingPathExtension] stringByAppendingPathExtension:TIOModelBundleExtension];
        NSString *dst = [modelsPath stringByAppendingPathComponent:dstFilename];
        NSString *src = [modelsPath stringByAppendingPathComponent:filename];
        NSError *error;
        
        NSLog(@"Renamed %@ to %@", src.lastPathComponent, dst.lastPathComponent);
        
        if (![fm moveItemAtPath:src toPath:dst error:&error]) {
            NSLog(@"Unable to rename %@, error: %@", src, error);
        }
    }
}

@end
