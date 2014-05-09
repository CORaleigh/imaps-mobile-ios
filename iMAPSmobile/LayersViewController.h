//
//  LayersViewController.h
//  iMAPSmobile
//
//  Created by Justin Greco on 10/8/13.
//  Copyright (c) 2013 City of Raleigh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>
@interface LayersViewController : UITableViewController<AGSMapServiceInfoDelegate, AGSLayerDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) AGSJSONRequestOperation *jsonOp;
@property (strong, nonatomic) NSOperationQueue *queue;
@property (strong, nonatomic) NSMutableArray *opLayers;
@property (strong, nonatomic) AGSMapView *mapView;
@property (strong, nonatomic) IBOutlet UITableView *layerTableView;
@property (strong, nonatomic) AGSLayer *selectedLayer;
@end
