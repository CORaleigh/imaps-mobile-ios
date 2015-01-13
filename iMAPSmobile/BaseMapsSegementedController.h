//
//  BaseMapsSegementedController.h
//  iMAPSmobile
//
//  Created by Justin Greco on 12/13/13.
//  Copyright (c) 2013 City of Raleigh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>
@interface BaseMapsSegementedController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, AGSLayerDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;
- (IBAction)segmentChanged:(id)sender;
@property (weak, nonatomic) IBOutlet UIPickerView *picker;
@property (weak, nonatomic) IBOutlet UISwitch *labelSwitch;
@property (weak, nonatomic) IBOutlet UILabel *label;
- (IBAction)labelsToggled:(id)sender;

@property (strong, nonatomic) AGSJSONRequestOperation *jsonOp;
@property (strong, nonatomic) NSOperationQueue *queue;
@property (strong, nonatomic) NSMutableArray *baseLayers;
@property (strong, nonatomic) NSMutableArray *imageLayers;
@property (strong, nonatomic) AGSMapView *mapView;
@property (strong, nonatomic) AGSLayer *layer;
@property (strong, nonatomic) AGSPolygon *raleighBounds;

@end
