//
//  LayerDetailsViewController.h
//  iMAPSmobile
//
//  Created by Justin Greco on 10/9/13.
//  Copyright (c) 2013 City of Raleigh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>


@interface LayerDetailsViewController : UITableViewController<AGSMapServiceInfoDelegate>
@property (strong, nonatomic) NSArray *layerInfos;
@property (strong, nonatomic) AGSLayer *layer;
@property (strong, nonatomic) AGSMapServiceInfo *mapServiceInfo;
@end
