//
//  AddressesViewController.h
//  iMAPSmobile
//
//  Created by Justin Greco on 11/8/13.
//  Copyright (c) 2013 City of Raleigh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>

@interface AddressesViewController : UITableViewController
@property (strong, nonatomic) NSMutableDictionary *params;
@property (strong, nonatomic) AGSJSONRequestOperation *jsonOp;
@property (strong, nonatomic) NSOperationQueue *queue;
@property (strong, nonatomic) NSArray *addresses;
@property (strong, nonatomic) NSString *pin;
@property CGFloat customRowHeight;

@end
