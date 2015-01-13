//
//  DeedsViewController.h
//  iMAPSmobile
//
//  Created by Justin Greco on 10/11/13.
//  Copyright (c) 2013 City of Raleigh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>
@interface DeedsViewController : UITableViewController <UIAlertViewDelegate>
@property (strong, nonatomic) NSString *reid;
@property (strong, nonatomic) AGSJSONRequestOperation *jsonOp;
@property (strong, nonatomic) NSOperationQueue *queue;
@property (strong, nonatomic) NSMutableDictionary *deeds;
@property (strong, nonatomic) NSURL *deedUrl;
@end
