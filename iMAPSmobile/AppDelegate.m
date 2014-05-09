//
//  AppDelegate.m
//  MasterDetailTest
//
//  Created by Justin Greco on 10/4/13.
//  Copyright (c) 2013 City of Raleigh. All rights reserved.
//

#import "AppDelegate.h"
#import "GAI.h"
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
    
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 20;
    
    // Optional: set Logger to VERBOSE for debug information.
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
    
    // Initialize tracker.
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-11110258-21"];
    
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
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self testNetworkConnection];
    }
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self testNetworkConnection];
}

- (void) handleNetworkUnavailable {
    UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"Connection Issue"
												 message:@"Internet Connection Not Detected"
												delegate:self cancelButtonTitle:@"Retry"
									   otherButtonTitles:nil];
	[av show];
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
    NSURL* url = [NSURL URLWithString:@"http://maps.raleighnc.gov/iMAPS_iOS/iMAPS_Alert.txt"];
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
    if ([[results objectForKey:@"show"] isEqualToString:@"true"]) {
        UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"iMAPS Alert"
                                                     message:[results objectForKey:@"message"]
                                                    delegate:nil cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
        [av show];
    }
}

@end
