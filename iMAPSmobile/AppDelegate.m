//
//  AppDelegate.m
//  MasterDetailTest
//
//  Created by Justin Greco on 10/4/13.
//  Copyright (c) 2013 City of Raleigh. All rights reserved.
//

#import "AppDelegate.h"
#import "Reachability.h"

@implementation AppDelegate

@synthesize jsonOp = _jsonOp, queue = _queue;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
        UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
        splitViewController.delegate = (id)navigationController.topViewController;
        if ([splitViewController respondsToSelector:@selector(setPresentsWithGesture:)]) {
            [splitViewController setPresentsWithGesture:NO];
        }
    }
    

    // Set the client ID
    NSError *error;
    NSString* clientID = @"EUzoWXzqk67qQ4bd";
    [AGSRuntimeEnvironment setClientID:clientID error:&error];
    if(error){
        // We had a problem using our client ID
        NSLog(@"Error using client ID : %@",[error localizedDescription]);
    }

    
    return YES;
}



-(BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder
{
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
   // if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self testNetworkConnection];
  //  }
}


- (void) handleNetworkUnavailable {
    self.viewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    if ( self.viewController.presentedViewController && !self.viewController.presentedViewController.isBeingDismissed ) {
        self.viewController = self.viewController.presentedViewController;
    }
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:NSLocalizedString(@"No Internet Connection", nil)
                                 message:NSLocalizedString(@"Internet Connection Not Detected", nil)
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* okButton = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"Retry", nil)
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   [self.viewController.navigationController popViewControllerAnimated:YES];
                               }];
    [alert addAction:okButton];
    
    [self.viewController  presentViewController:alert animated:YES completion:nil];
}

- (void) testNetworkConnection {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        [self handleNetworkUnavailable];
    } else {
        [self getConfig];
    }
}

- (void) getConfig {
    self.queue = [[NSOperationQueue alloc] init];
    NSURL* url = [NSURL URLWithString:@"https://maps.raleighnc.gov/iMAPS_iOS/alert.json"];
    self.jsonOp.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    self.jsonOp.timeoutInterval = 10;
    self.jsonOp = [[AGSJSONRequestOperation alloc] initWithURL:url];
    self.jsonOp.target = self;
    self.jsonOp.action = @selector(operation:didSucceedWithResponse:);

    [self.queue addOperation:self.jsonOp];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)operation:(NSOperation*)op didSucceedWithResponse:(NSDictionary *) results {
    if ([[results objectForKey:@"enabled"] isEqualToString:@"true"]) {
        self.viewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
        if ( self.viewController.presentedViewController && !self.viewController.presentedViewController.isBeingDismissed ) {
            self.viewController = self.viewController.presentedViewController;
        }
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:NSLocalizedString(@"Alert", nil)
                                     message:[results objectForKey:@"message"]
                                     preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okButton = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"OK", nil)
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       [self.viewController.navigationController  popViewControllerAnimated:YES];
                                   }];
        [alert addAction:okButton];
        
        [self.viewController presentViewController:alert animated:YES completion:nil];
        
    }
}

@end
