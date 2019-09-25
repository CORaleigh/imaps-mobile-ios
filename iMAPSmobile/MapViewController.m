//
//  ViewController.m
//  iMAPSmobile
//
//  Created by Justin Greco on 10/2/13.
//  Copyright (c) 2013 City of Raleigh. All rights reserved.
//

#import "MapViewController.h"
#import "AppDelegate.h"
#import "SingletonData.h"
#import "ResultsViewController.h"
#import "InfoViewController.h"
#import "LayersViewController.h"
#import "BaseMapsSegementedController.h"
#import "SearchController.h"
#import "SVProgressHUD.h"
#import "Reachability.h"

@interface MapViewController ()
//@property (strong, nonatomic) UIPopoverController *masterPopoverController;
-(void)configureView;
@end

@implementation MapViewController

@synthesize property = _property, propertyGl = _propertyGl, queryTask = _queryTask, query
 = _query, pin = _pin, account = _account, accounts = _accounts, fields = _fields, gpsButton = _gpsButton, idTask = _idTask, idParams = _idParams, idCount = _idCount, idTotal = _idTotal, idResults = _idResults, idGraphic = _idGraphic, lastView = _lastView, geoService = _geoService, streetViewUrl = _streetViewUrl;
@synthesize jsonOp = _jsonOp;
@synthesize queue = _queue;


#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }

}

- (void)configureView
{
    // Update the user interface for the detail item.
    
    if (self.detailItem) {
        self.detailDescriptionLabel.text = [self.detailItem description];
    }
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureView];

    
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.toolbarHidden = NO;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.toolbar.translucent = NO;
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [button addTarget:self action:@selector(infoPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *infoItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchPressed:)];
    
    NSArray *buttonArray;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        buttonArray= [[NSArray alloc] initWithObjects:infoItem, nil];
    } else {
        buttonArray= [[NSArray alloc] initWithObjects:infoItem, searchItem, nil];
    }
    

    self.navigationItem.rightBarButtonItems = buttonArray;
    
    if (![SingletonData getSingleTapName]) {
        [SingletonData setSingleTapName:@"identify"];
    }
    
    self.queue = [[NSOperationQueue alloc] init];
    
    if ([SingletonData getBaseLayer]) {
        [self.mapView addMapLayer:[self getBaseLayer:[SingletonData getBaseLayer]]];
    } else {
        [self testNetworkConnection];
    }
    
    [self.mapView setBackgroundColor:[AGSColor darkGrayColor]];
    [self.mapView setGridLineColor:[AGSColor clearColor]];
    [self.mapView setGridLineWidth:0.00];
    
    if ([SingletonData getLabels]) {
        [self.mapView addMapLayer:[SingletonData getLabels]];
    }
    

    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addGraphic:) name:@"addGraphicNotification" object:nil];
    self.mapView.layerDelegate = self;
    self.mapView.touchDelegate = self;
    // register for zoom notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToEnvChange:)
                                                 name:AGSMapViewDidEndZoomingNotification object:nil];
    
    NSURL *url = [NSURL URLWithString:@"https://maps.raleighnc.gov/ArcGIS/rest/services/Property/Property/MapServer/0"];
    self.queryTask = [[AGSQueryTask alloc] initWithURL:url];
    self.queryTask.delegate = self;
    

    self.idTask = [[AGSIdentifyTask alloc] init];
    self.idParams = [[AGSIdentifyParameters alloc]init];
    
   
    
    self.query = [AGSQuery query];
    
}






- (void) handleNetworkUnavailable {
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:NSLocalizedString(@"Connection Issue", nil)
                                 message:NSLocalizedString(@"Internet Connection Not Detected", nil)
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* okButton = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"Retry", nil)
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   [self testNetworkConnection];
                               }];
    [alert addAction:okButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) testNetworkConnection {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        [self handleNetworkUnavailable];
    } else {
        [self getConfig];
    }
}

- (void) getConfig {
    NSURL *url = [NSURL URLWithString:@"https://maps.raleighnc.gov/iMAPS_iOS/config.txt"];
    self.jsonOp = [[AGSJSONRequestOperation alloc] initWithURL:url];
    self.jsonOp.target = self;
    self.jsonOp.action = @selector(operation:didSucceedWithConfig:);
    self.jsonOp.errorAction = @selector(operation:didFailWithConfig:);
    [self.queue addOperation:self.jsonOp];
}

- (void)operation:(NSOperation*)op didSucceedWithConfig:(NSDictionary *)results {
    NSArray *baseLayers = [results objectForKey:@"BaseMapLayers"];
    NSDictionary *baseLayer = [baseLayers objectAtIndex:0];
    [SingletonData setBaseLayer:baseLayer];
    NSURL *url = [NSURL URLWithString:[baseLayer objectForKey:@"url"]];
    AGSTiledMapServiceLayer *tiledLayer = [AGSTiledMapServiceLayer tiledMapServiceLayerWithURL:url];
    [self.mapView addMapLayer:tiledLayer withName:@"Base Map"];
    [self.mapView centerAtPoint:[AGSPoint pointWithX:2106483 y:746916 spatialReference:self.mapView.spatialReference] animated:NO];
    [self addLabelsMapService];
}

- (void)operation:(NSOperation*)op didFailWithConfig:(NSDictionary *) error {
    
}

- (void) addLabelsMapService {
    NSURL *url = [NSURL URLWithString:@"https://maps.raleighnc.gov/arcgis/rest/services/Labels/MapServer"];
    AGSTiledMapServiceLayer *labelsLayer = [AGSTiledMapServiceLayer tiledMapServiceLayerWithURL:url];
    [labelsLayer setVisible:NO];
    [self.mapView addMapLayer:labelsLayer withName:@"Labels"];
    [SingletonData setLabels:labelsLayer];
}

-(AGSLayer*)getBaseLayer:(NSDictionary *)layer {
    NSString *type = [layer objectForKey:@"type"];
    NSURL *url = [NSURL URLWithString:[layer objectForKey:@"url"]];
    AGSLayer *baseLayer;
    if ([type isEqualToString:@"tiled"]) {
        baseLayer = [AGSTiledMapServiceLayer tiledMapServiceLayerWithURL:url];
    } else if ([type isEqualToString:@"dynamic"]) {
        baseLayer = [AGSDynamicMapServiceLayer dynamicMapServiceLayerWithURL:url];
    }
    [baseLayer setName:[layer objectForKey:@"name"]];
    [baseLayer setOpacity:(CGFloat)[[layer objectForKey:@"opacity"] floatValue]];
    return baseLayer;
}

// The method that should be called when the notification arises
- (void)respondToEnvChange: (NSNotification*) notification {
    if (self.mapView.mapScale < 600) {
        [self.mapView zoomToScale:601 animated:NO];
    }
    
}




-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.toolbarHidden = NO;
    self.navigationController.toolbar.userInteractionEnabled = YES;
    self.navigationController.navigationBar.userInteractionEnabled = YES;
    
}



-(void)mapViewDidLoad:(AGSMapView*) mapView {
    _propertyGl = [AGSGraphicsLayer graphicsLayer];
    [self.mapView addMapLayer:_propertyGl withName:@"Property Selection"];
    
    if(mapView.loaded)
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            if(_property)
            {
                [self addGraphicToMap:self.property];
                [self.mapView zoomToGeometry:self.property.geometry withPadding:50 animated:TRUE];
            } else if ([SingletonData getMapView]) {
                AGSMapView *savedMap = [SingletonData getMapView];
                [self.mapView zoomToEnvelope:savedMap.visibleArea.envelope animated:NO];
            } else {
                //[self setIsGpsOn:YES];
                //[self startGPS];
            }
        }




        
        if ([SingletonData getLayersJson]) {
            for(int i = 0;i < [[SingletonData getLayersJson] count];i++) {
                //[self.mapView addMapLayer:[savedMap.mapLayers objectAtIndex:i]];
                NSDictionary *layer = [[SingletonData getLayersJson] objectAtIndex:i];
                BOOL visible = (BOOL)[[layer objectForKey:@"visible"] boolValue];
                if (visible) {
                    [self.mapView addMapLayer:[self getBaseLayer:layer]];
                }
            }
        }
        
        
        
        [SingletonData setMapView:self.mapView];
    }
}

- (void) locationDisplayDataSource:(id<AGSLocationDisplayDataSource>)dataSource didUpdateWithLocation:(AGSLocation *)location {
    if (!self.isInCounty && self.isGpsOn) {
        NSString *json = @"{\"rings\": [[[-78.56550115447668, 36.03449602470425], [-78.42326717734176, 35.97966361038317], [-78.39038853588526, 35.94189495374762], [-78.34898333486737, 35.93529827766309], [-78.34435556834683, 35.91381850068721], [-78.30323093120224, 35.90119742854354], [-78.27239586544991, 35.87040299454307], [-78.250827815716, 35.81456428686692], [-78.4643129005494, 35.70277825544956], [-78.70691997800822, 35.51422297642292], [-78.99947626904721, 35.606018808935474], [-79.00154815690348, 35.61165688701909], [-78.91186490639764, 35.87092605041272], [-78.83478482993546, 35.8725475419026], [-78.80957195171227, 35.931468933540316], [-78.76173672117416, 35.92458060700787], [-78.72314152363272, 35.96383870989089], [-78.70686845786462, 36.00999209153113], [-78.72186083160868, 36.0231723305738], [-78.74117146869936, 36.018126360251], [-78.75941444890343, 36.02855657798121], [-78.75658571230598, 36.07424230841746], [-78.68139706931657, 36.07944763271822], [-78.56550115447668, 36.03449602470425]]],\"spatialReference\": {\"wkid\": 4326}}";
        AGSPolygon *wakeBounds = [AGSPolygon polygonWithJSON: [json ags_JSONValue]];
        if (![wakeBounds containsPoint:location.point]) {
            self.isGpsOn = false;
            self.gpsButton.title = NSLocalizedString(@"GPS Off", nil);
            [self.gpsButton setImage: [UIImage imageNamed:@"gps"]];
            [self.mapView.locationDisplay stopDataSource];

            UIAlertController * alert = [UIAlertController
                                         alertControllerWithTitle:NSLocalizedString(@"Sorry", nil)
                                         message:NSLocalizedString(@"You are currently located outside of Wake County", nil)
                                         preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* okButton = [UIAlertAction
                                       actionWithTitle:NSLocalizedString(@"OK", nil)
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action) {
                                       }];
            [alert addAction:okButton];
            
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            self.isInCounty = true;
            [self.mapView.locationDisplay stopDataSource];
        }
    }
}

- (void) locationDisplayDataSource:(id<AGSLocationDisplayDataSource>)dataSource didFailWithError:(NSError *)error {
    
}

- (void) locationDisplayDataSourceStopped:(id<AGSLocationDisplayDataSource>)dataSource {
    
}

- (void) locationDisplayDataSource:(id<AGSLocationDisplayDataSource>)dataSource didUpdateWithHeading:(double)heading {
    
}

- (void) locationDisplayDataSourceStarted:(id<AGSLocationDisplayDataSource>)dataSource {
    
}

-(void)startGPS {
    if (self.isGpsOn) {
        //[self.mapView.locationDisplay.dataSource setDelegate:self];
        [self.mapView.locationDisplay addObserver:self forKeyPath:@"location" options:(NSKeyValueObservingOptionNew) context:NULL];
        self.mapView.locationDisplay.autoPanMode = AGSLocationDisplayAutoPanModeDefault;
        self.gpsButton.title = NSLocalizedString(@"GPS On", nil);
        [self.gpsButton setImage: [UIImage imageNamed:@"gps-on"]];

        [self.mapView.locationDisplay startDataSource];
        
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqual:@"location"]) {
        NSLog(@"Location updated to %@", [self.mapView.locationDisplay mapLocation]);
        [self checkGpsInCounty:[self.mapView.locationDisplay mapLocation]];
        [self.mapView.locationDisplay removeObserver:self forKeyPath:@"location"];
    }
}

- (void)checkGpsInCounty:(AGSPoint *) location {
    if (!self.isInCounty && self.isGpsOn) {
        NSString *json = @"{\"rings\": [[[2128469,831736],[2170639,811991],[2180451,798301],[2192723,795977],[2194145,788167],[2206354,783656],[2215568,772513],[2222112,752236],[2159039,711137],[2087214,642208],[2000155,675490],[1999539,677542],[2026112,771925],[2048947,772544],[2056376,794005],[2070543,791529],[2081931,805849],[2086697,822663],[2082249,827448],[2076544,825596],[2071139,829379],[2071935,846012],[2094149.617890,847970],[2128469,831736]]],\"spatialReference\": {\"wkid\": 2246}}";
        AGSPolygon *wakeBounds = [AGSPolygon polygonWithJSON: [json ags_JSONValue]];
        if (![wakeBounds containsPoint:location]) {
            self.isGpsOn = false;
            self.gpsButton.title = NSLocalizedString(@"GPS Off", nil);
            [self.gpsButton setImage: [UIImage imageNamed:@"gps"]];

            [self.mapView.locationDisplay stopDataSource];


            UIAlertController * alert = [UIAlertController
                                         alertControllerWithTitle:NSLocalizedString(@"Sorry", nil)
                                         message:NSLocalizedString(@"You are currently located outside of Wake County", nil)
                                         preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* okButton = [UIAlertAction
                                       actionWithTitle:NSLocalizedString(@"OK", nil)
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action) {
                                       }];
            [alert addAction:okButton];
            
            [self presentViewController:alert animated:YES completion:nil];
            
        } else {
            self.isInCounty = true;
        }
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [SingletonData setMapView:self.mapView];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.gpsButton.title = NSLocalizedString(@"GPS Off", nil);
    [self.gpsButton setImage: [UIImage imageNamed:@"gps"]];

    [[self.mapView locationDisplay] stopDataSource];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)addGraphicToMap:(AGSGraphic*) data {
    if(self.mapView.loaded) {
        
        AGSSimpleLineSymbol *sls = [AGSSimpleLineSymbol simpleLineSymbolWithColor:[UIColor redColor] width:4];
        AGSSimpleFillSymbol *sfs = [AGSSimpleFillSymbol simpleFillSymbol];
        sfs.outline = sls;
        sfs.style = AGSSimpleFillSymbolStyleNull;
        [data setSymbol:sfs];
        [_propertyGl removeAllGraphics];
        [_propertyGl addGraphic:data];
        
    }

}


-(void)addGraphic: (NSNotification*) notification {
    self.property = [notification.userInfo objectForKey:@"graphic"];
    [self.mapView zoomToGeometry:self.property.geometry withPadding:50 animated:TRUE];
    [self addGraphicToMap:self.property];
    
}



#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willChangeToDisplayMode:(UISplitViewControllerDisplayMode)displayMode  {
    if (splitController.displayMode != UISplitViewControllerDisplayModePrimaryHidden)
    {
        UIBarButtonItem *barButtonItem = splitController.displayModeButtonItem;


        self.navigationItem.leftBarButtonItem = barButtonItem;
    }
}

-(void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];

    if (@available(iOS 13, *)) {
        if(self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
            self.navigationController.navigationBar.barTintColor = [UIColor blackColor];

        } else {
            self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];

        }
    }
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (@available(iOS 13, *)) {
        if(self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
            self.navigationController.navigationBar.barTintColor = [UIColor blackColor];

        } else {
            self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
        }
    }
    if (self.splitViewController.displayMode == UISplitViewControllerDisplayModePrimaryHidden)
    {
        UIBarButtonItem *barButtonItem = self.splitViewController.displayModeButtonItem;


        self.navigationItem.leftBarButtonItem = barButtonItem;
    }
    
    
}


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
    NSMutableDictionary* info = [NSMutableDictionary dictionary];
//
    if ([[segue identifier] isEqualToString:@"mapToLayers"]){
        if ([segue.destinationViewController respondsToSelector:@selector(setMapView:)]) {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                UIViewController *dvc = segue.destinationViewController;
                UIPopoverPresentationController *controller = dvc.popoverPresentationController;
                if (controller) {
                    controller.delegate = self;
                }
            } else {
                [segue.destinationViewController performSelector:@selector(setMapView:)
                                                      withObject:_mapView];
            }
        }
    }
    else if ([[segue identifier] isEqualToString:@"mapToBasemaps"]){
        if ([segue.destinationViewController respondsToSelector:@selector(setMapView:)]) {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                UIViewController *dvc = segue.destinationViewController;
                UIPopoverPresentationController *controller = dvc.popoverPresentationController;
                if (controller) {
                    controller.delegate = self;
                }
            } else {
                [segue.destinationViewController performSelector:@selector(setMapView:)
                                                      withObject:_mapView];
            }
        }
    } else if ([[segue identifier] isEqualToString:@"mapToResults"]){
        if ([segue.destinationViewController respondsToSelector:@selector(setInfo:)]) {
            [info setObject:self.fields forKey:@"fields"];
            [info setObject:self.accounts forKey:@"accounts"];
            [segue.destinationViewController performSelector:@selector(setInfo:)
                                                  withObject:info];
        }
    } else if ([[segue identifier] isEqualToString:@"mapToInfo"]){
        if ([segue.destinationViewController respondsToSelector:@selector(setInfo:)]) {
            [info setObject:self.fields forKey:@"fields"];
            [info setObject:self.account forKey:@"account"];
            [segue.destinationViewController performSelector:@selector(setInfo:)
                                                  withObject:info];
        }
    }
}


- (IBAction)viewMaps:(id)sender {
    [self performSegueWithIdentifier:@"mapToBasemaps" sender:self];
}

#pragma mark - AGSMapViewTouchDelegate Methods
-(void)mapView:(AGSMapView *)mapView didTapAndHoldAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint features:(NSDictionary *)features {

    self.query.geometry = mappoint;
    self.query.whereClause = @"TAXABLE_STATUS = 'ACTIVE'";
    self.query.outFields = [NSArray arrayWithObjects:@"PIN_NUM", nil];
    self.query.returnGeometry = NO;
    [SVProgressHUD setDefaultMaskType: SVProgressHUDMaskTypeBlack];
    [SVProgressHUD show];
    [self.queryTask executeWithQuery:self.query];
}

-(void)mapView:(AGSMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint features:(NSDictionary *)features{
        [self identify:mapView mappoint:mappoint];
}
- (void) identify : (AGSMapView *) mapView mappoint: (AGSPoint *) mappoint {
    NSArray *opLayers = [SingletonData getLayersJson];
    self.idCount = 0;
    self.idTotal = 0;
    self.idResults = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [opLayers count];i++) {
        NSDictionary *layer = [opLayers objectAtIndex:i];
        if ((BOOL)[[layer objectForKey:@"visible"] boolValue]) {
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [layer objectForKey:@"url"], @"/Identify"]];
            NSMutableDictionary* params = [NSMutableDictionary dictionary];
            [params setObject:@"json" forKey:@"f"];
            [params setObject:@"10" forKey:@"tolerance"];
            [params setObject:[mappoint encodeToJSON] forKey:@"geometry"];

            [params setObject:@"esriGeometryPoint" forKey:@"geometryType"];
            [params setObject:[mapView.visibleAreaEnvelope encodeToJSON] forKey:@"mapExtent"];
            [params setObject:@"visible" forKey:@"layers"];
            [params setObject:@"false" forKey:@"returnGeometry"];
            [params setObject:[NSString stringWithFormat:@"%f,%f,%i", mapView.bounds.size.height, mapView.bounds.size.width, 96] forKey:@"imageDisplay"];
            
            self.jsonOp = [[AGSJSONRequestOperation alloc]initWithURL:url queryParameters:params];
            self.jsonOp.target = self;
            self.jsonOp.action = @selector(operation:didIdentify:);
            self.jsonOp.errorAction = @selector(operation:didFailWithError:);
            self.idTotal += 1;
            [self.queue addOperation:self.jsonOp];
        }
    }
}



- (void)operation:(NSOperation*)op didIdentify:(NSDictionary *)results {
    [self.idResults addObject:[results objectForKey:@"results"]];
    self.idCount += 1;
    if (self.idCount == self.idTotal) {
        [self reportIdResults: self.idGraphic];
    }
}

#pragma mark AGSQueryTaskDelegate
-(void)queryTask:(AGSQueryTask *)queryTask operation:(NSOperation *)op didExecuteWithFeatureSetResult:(AGSFeatureSet *)featureSet {
    
    if ([featureSet.features count] > 0) {
        AGSGraphic *graphic = [featureSet.features objectAtIndex:0];
        [self addGraphicToMap:graphic];
        NSString *pin = [graphic attributeAsStringForKey:@"PIN_NUM"];

        [self searchByPIN:pin];
    } else {
        [SVProgressHUD dismiss];
    }
}

-(void)queryTask:(AGSQueryTask *)queryTask operation:(NSOperation *)op didFailWithError:(NSError *)error {
    [SVProgressHUD dismiss];
}


#pragma mark AGSIdentifyTaskDelegate
-(void)identifyTask:(AGSIdentifyTask *)identifyTask operation:(NSOperation *)op didExecuteWithIdentifyResults:(NSArray *)results {
    [SVProgressHUD dismiss];
    [self.idResults addObject:results];
    self.idCount += 1;
    if (self.idCount == self.idTotal) {
        [self reportIdResults: self.idGraphic];
    }
}

-(void)identifyTask:(AGSIdentifyTask *)identifyTask operation:(NSOperation *)op didFailWithError:(NSError *)error {
    [SVProgressHUD dismiss];
}

-(void)reportIdResults:(AGSGraphic *)graphic{
    NSMutableArray *popups = [[NSMutableArray alloc] init];
    //if ([[self.idResults objectAtIndex:0] count] > 0) {
        
        for (int i = 0; i < [self.idResults count]; i++) {
            NSArray *results =[self.idResults objectAtIndex:i];
            if ([results count] > 0) {
                for (int j = 0; j < [results count]; j++) {
                    //AGSIdentifyResult *result = [results objectAtIndex:j];
                    
                    NSDictionary *result = [results objectAtIndex:j];
                    NSDictionary* atts = [result objectForKey:@"attributes"];
                    NSArray* keys = [atts allKeys];
                    NSMutableDictionary* attributes = [[NSMutableDictionary alloc] init];
                    for (NSString* key in keys) {
                        if (![[atts objectForKey:key] isEqualToString:@"Null"]) {
                            [attributes setObject:[atts objectForKey:key] forKey:key];
                        }
                    }
                    
                    
                    
                    AGSGraphic *g = [AGSGraphic graphicWithGeometry:nil symbol:nil attributes:attributes];
                    
                    
                    //AGSPopupInfo *popupInfo = [[AGSPopupInfo alloc] init];
                    AGSPopupInfo *popupInfo = [AGSPopupInfo popupInfoForGraphic:g];
                    popupInfo.title = [result objectForKey:@"layerName"];
                    
                    for (int k = 0; k < [popupInfo.fieldInfos count]; k++) {
                        AGSPopupFieldInfo *info = [popupInfo.fieldInfos objectAtIndex:k];
                        if ([info.fieldName.uppercaseString isEqualToString:@"SHAPE"] || [info.fieldName.uppercaseString isEqualToString:@"OBJECTID"] || [info.fieldName.uppercaseString isEqualToString:@"PARCEL_PK"]) {
                            info.visible = NO;
                        }
                    }
                    
                    AGSPopup* popup = [AGSPopup popupWithGraphic:g popupInfo:popupInfo];
                    [popups addObject:popup];
                }
            }

      //  }

    }
    if ([popups count] > 0) {
        AGSPopupsContainerViewController* popupVC = [[AGSPopupsContainerViewController alloc] initWithPopups:popups usingNavigationControllerStack:false];
        popupVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        popupVC.modalPresentationStyle = UIModalPresentationFormSheet;
        popupVC.delegate = self;
        [self presentViewController:popupVC animated:YES completion:nil];
        
    }
}

-(void)popupsContainerDidFinishViewingPopups:(id<AGSPopupsContainer>)popupsContainer {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)searchByPIN:(NSString *) pin{
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setObject:@"json" forKey:@"f"];
    [params setObject:[[@"PIN_NUM = '" stringByAppendingString:pin] stringByAppendingString:@"'"] forKey:@"where"];
    [params setObject:@"*" forKey:@"outFields"];
    [params setObject:@"false" forKey:@"returnGeometry"];

    NSURL* url = [NSURL URLWithString:@"https://maps.raleighnc.gov/arcgis/rest/services/Property/Property/MapServer/1/query"];

    self.jsonOp = [[AGSJSONRequestOperation alloc]initWithURL:url queryParameters:params];
    self.jsonOp.target = self;
    self.jsonOp.action = @selector(operation:didSucceedWithAccounts:);
    self.jsonOp.errorAction = @selector(operation:didFailWithError:);
    
    [self.queue addOperation:self.jsonOp];
}


- (void)operation:(NSOperation*)op didSucceedWithAccounts:(NSDictionary *)results {
    [SVProgressHUD dismiss];
    if ([results objectForKey:@"features"] != nil) {
        
        
        self.accounts = [results objectForKey:@"features"];
        self.fields = [results objectForKey:@"fields"];
        self.account = [self.accounts objectAtIndex:0];
        
        if (self.accounts.count > 1) {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                [self reportResultsOnIpad];
            } else {
                [self performSegueWithIdentifier:@"mapToResults" sender:self];
            }
        } else {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                [self reportPropertyInfoOnIpad];
            }
            else {
                [self performSegueWithIdentifier:@"mapToInfo" sender:self];
            }
            
            
        }
    }
}

- (void)operation:(NSOperation*)op didFailWithError:(NSError *)error {
	//Error encountered while invoking webservice. Alert user
    [SVProgressHUD dismiss];

    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:NSLocalizedString(@"Sorry", nil)
                                 message:[error localizedDescription]
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* okButton = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"OK", nil)
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                               }];
    [alert addAction:okButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}


-(void)reportResultsOnIpad{
    //load results view controller in master view//
    NSArray *controllers = self.splitViewController.viewControllers;
    UINavigationController *controller = [controllers objectAtIndex:0];
    UIViewController *currentController = nil;
    if ([controller.viewControllers count] > 1) {
        currentController = [controller.viewControllers objectAtIndex:1];
    } else {
        currentController = [controller.viewControllers objectAtIndex:0];
    }
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setObject:self.fields forKey:@"fields"];
    [dict setObject:self.accounts forKey:@"accounts"];
    if (![currentController isKindOfClass:([ResultsViewController class])]) {
//
//
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPad" bundle:[NSBundle mainBundle]];
       ResultsViewController *rvc = [storyboard instantiateViewControllerWithIdentifier:@"resultsViewController"];
       NSMutableArray *vcs = [[NSMutableArray alloc] initWithObjects:rvc, nil];
        [controller setViewControllers:vcs];
        //add notifier to results view controller//
        //[[NSNotificationCenter defaultCenter] addObserver:rvc selector:@selector(showResults:) name:@"showResultsNotification" object:nil];
//
        SEL selector = sel_registerName("showResults:");
        [[NSNotificationCenter defaultCenter] addObserver:rvc selector:selector name:@"showResultsNotification" object: nil];

    } else {
//        //notify results view controller of results//
//
    }
    [[NSNotificationCenter defaultCenter] postNotificationName: @"showResultsNotification" object: self userInfo: dict];

}


-(void)reportPropertyInfoOnIpad{
    //load property info view controller in master view//
    NSArray *controllers = self.splitViewController.viewControllers;
    UINavigationController *controller = [controllers objectAtIndex:0];
    UIViewController *currentController = [controller.viewControllers objectAtIndex:[controller.viewControllers count]-1];
    if (![currentController isKindOfClass:([InfoViewController class])]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPad" bundle:[NSBundle mainBundle]];
        InfoViewController *ivc = [storyboard instantiateViewControllerWithIdentifier:@"infoViewController"];
        NSMutableArray *vcs = [[NSMutableArray alloc] initWithObjects:ivc, nil];
        [controller setViewControllers:vcs];
        //add notifier to property info  view controller//
        //[[NSNotificationCenter defaultCenter] addObserver:ivc selector:@selector(showProperty:) name:@"showPropertyNotification" object:nil];
        SEL selector = sel_registerName("showProperty:");
        [[NSNotificationCenter defaultCenter] addObserver:ivc selector:selector name:@"showPropertyNotification" object:nil];
    }
    //notify property info view controller of results//
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setObject:self.fields forKey:@"fields"];
    [dict setObject:self.account forKey:@"account"];
    [[NSNotificationCenter defaultCenter] postNotificationName: @"showPropertyNotification" object: self userInfo: dict];
}



 


-(void)setIsGpsOn:(BOOL)isGpsOn {
    _isGpsOn = isGpsOn;
}
- (IBAction)gpsButtonTapped:(id)sender {
    self.mapView.locationDisplay.autoPanMode = AGSLocationDisplayAutoPanModeDefault;
    if (self.isGpsOn) {
        self.gpsButton.title = NSLocalizedString(@"GPS Off", nil);
        [self.gpsButton setImage: [UIImage imageNamed:@"gps"]];

        [self setIsGpsOn:NO];
        [self.mapView.locationDisplay stopDataSource];
    } else {
        [self setIsGpsOn:YES];
        [self startGPS];
    }
}



- (IBAction)viewLayers:(id)sender {
    [self performSegueWithIdentifier:@"mapToLayers" sender:self];

}

- (IBAction)infoPressed:(id)sender {

    [self performSegueWithIdentifier:@"mapSettings" sender:self];
}



- (IBAction)searchPressed:(id)sender {
    [self performSegueWithIdentifier:@"mapToSearch" sender:self];
}
@end
