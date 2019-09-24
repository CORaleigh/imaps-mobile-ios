//
//  ViewController.h
//  iMAPSmobile
//
//  Created by Justin Greco on 10/2/13.
//  Copyright (c) 2013 City of Raleigh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>
#import "BaseMapsSegementedController.h"
@interface MapViewController : UIViewController<UISplitViewControllerDelegate, UIPopoverControllerDelegate,AGSMapViewLayerDelegate, AGSMapViewTouchDelegate, AGSQueryTaskDelegate, AGSPopupsContainerDelegate,
 AGSGeometryServiceTaskDelegate, UIAlertViewDelegate, AGSLocationDisplayDataSourceDelegate, UIPopoverPresentationControllerDelegate>

@property (weak, nonatomic) IBOutlet AGSMapView *mapView;
@property (strong, nonatomic) AGSGraphic *property;
@property (strong, nonatomic) AGSGraphicsLayer *propertyGl;
@property (strong, nonatomic) id detailItem;
@property (strong, nonatomic) AGSQueryTask *queryTask;
@property (strong, nonatomic) AGSQuery *query;
@property (strong, nonatomic) AGSIdentifyTask *idTask;
@property (strong, nonatomic) AGSIdentifyParameters *idParams;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (strong, nonatomic) NSString *pin;
@property (strong, nonatomic) AGSJSONRequestOperation *jsonOp;
@property (strong, nonatomic) NSOperationQueue *queue;
@property (strong, nonatomic) NSMutableArray *accounts;
@property (strong, nonatomic) NSDictionary *account;
@property (strong, nonatomic) NSMutableArray *fields;
@property (nonatomic, assign) BOOL isGpsOn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *gpsButton;
@property int idCount;
@property int idTotal;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *layerButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *mapsButton;

@property (strong, nonatomic)NSMutableArray *idResults;
@property (strong, nonatomic)AGSGraphic *idGraphic;
@property (strong, nonatomic) NSString *lastView;
@property (strong, nonatomic) NSURL *streetViewUrl;
@property (nonatomic, assign) BOOL isInCounty;
@property (strong, nonatomic) AGSGeometryServiceTask *geoService;
@property (strong, nonatomic) BaseMapsSegementedController *baseMapsController;




- (IBAction)viewLayers:(id)sender;
- (IBAction)infoPressed:(id)sender;
- (IBAction)searchPressed:(id)sender;

@end
