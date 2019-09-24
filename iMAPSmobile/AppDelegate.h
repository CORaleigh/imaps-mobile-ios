//
//  AppDelegate.h
//  iMAPSmobile
//
//  Created by Justin Greco on 10/2/13.
//  Copyright (c) 2013 City of Raleigh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, UISplitViewControllerDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) AGSJSONRequestOperation *jsonOp;
@property (strong, nonatomic) NSOperationQueue *queue;
@property (strong, nonatomic) UIViewController *viewController;

@end
