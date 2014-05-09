//
//  InfoViewController.h
//  iMAPSmobile
//
//  Created by Justin Greco on 10/7/13.
//  Copyright (c) 2013 City of Raleigh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>

@interface InfoViewController : UITableViewController<AGSFindTaskDelegate, UIActionSheetDelegate>
@property (strong, nonatomic) NSDictionary *info;
@property (strong, nonatomic) AGSFindTask *findTask;
@property (strong, nonatomic) AGSFindParameters *findParams;
@property (strong, nonatomic) AGSGraphic *graphic;
@end
