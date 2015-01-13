//
//  SepticPermitViewController.h
//  iMapsMobile
//
//  Created by Justin Greco on 10/16/14.
//  Copyright (c) 2014 City of Raleigh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SepticPermitViewController : UITableViewController
@property (nonatomic, strong) NSMutableArray *permits;
@property (strong, nonatomic) NSURL *septicUrl;
@end
