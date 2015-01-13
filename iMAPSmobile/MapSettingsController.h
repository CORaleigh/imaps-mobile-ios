//
//  MapSettingsController.h
//  iMAPSmobile
//
//  Created by Justin Greco on 12/17/13.
//  Copyright (c) 2013 City of Raleigh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapSettingsController : UIViewController
@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;
- (IBAction)dismissView:(id)sender;
- (IBAction)tapGestureChanged:(id)sender;

@end
