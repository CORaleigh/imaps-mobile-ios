//
//  LayersViewController.m
//  iMAPSmobile
//
//  Created by Justin Greco on 10/8/13.
//  Copyright (c) 2013 City of Raleigh. All rights reserved.
//

#import "LayersViewController.h"
#import "LayerDetailsViewController.h"
#import "SingletonData.h"
#import "LayerCell.h"
#import "LayerSwitch.h"
#import "LayerSlider.h"
#import "MapViewController.h"
#import "Reachability.h"

@interface LayersViewController ()

@end

@implementation LayersViewController {
}
@synthesize jsonOp = _jsonOp;
@synthesize queue = _queue;
@synthesize opLayers = _opLayers;
@synthesize mapView = _mapView;
@synthesize selectedLayer = _selectedLayer;
@synthesize layerTableView = _layerTableView;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    

    
    [self.navigationController setToolbarHidden:YES animated:NO];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    self.view.autoresizesSubviews = YES;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.queue = [[NSOperationQueue alloc] init];
    if ([SingletonData getLayersJson]) {
        _opLayers = [SingletonData getLayersJson];
    } else {
        [self testNetworkConnection];
    }

}


-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    self.navigationController.toolbar.userInteractionEnabled = YES;
    self.navigationController.navigationBar.userInteractionEnabled = YES;
    
}
-(void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    [self viewWillAppear:YES];

}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (@available(iOS 13, *)) {
        if(self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                self.navigationController.navigationBar.barTintColor = [UIColor systemGray5Color];
                [self.view setBackgroundColor:[UIColor systemGray5Color]];
                
            } else {
                self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
                [self.view setBackgroundColor:[UIColor blackColor]];
            }


        } else {
            self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
            [self.view setBackgroundColor:[UIColor whiteColor]];
        }
    }
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
    NSURL* url = [NSURL URLWithString:@"https://maps.raleighnc.gov/iMAPS_iOS/config.txt"];
    self.jsonOp = [[AGSJSONRequestOperation alloc] initWithURL:url];
    self.jsonOp.requestCachePolicy = NSURLRequestReloadIgnoringCacheData;
    self.jsonOp.target = self;
    self.jsonOp.action = @selector(operation:didSucceedWithReponse:);
    [self.queue addOperation:self.jsonOp];
}

- (void)operation:(NSOperation*)op didSucceedWithReponse:(NSDictionary *)results {
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    _opLayers = [NSMutableArray arrayWithArray:[[results objectForKey:@"OperationalLayers"] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]]];
    [SingletonData setLayersJson:_opLayers];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _opLayers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"LayerCell";
    LayerCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil){
        cell = [[LayerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSDictionary *layer = [_opLayers objectAtIndex:indexPath.row];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7) {
        CGRect frame = cell.label.frame;
        frame.origin.x = 105;
        [cell.label setFrame:frame];
    }
    
    
    BOOL visible = (BOOL)[[layer objectForKey:@"visible"] boolValue];
    
    if(visible) {
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
        [cell.onOff setTag:indexPath.row];

    
    cell.label.text = [layer objectForKey:@"name"];
    [cell.slider setValue:(CGFloat)[[layer objectForKey:@"opacity"] floatValue]];
    cell.slider.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    [cell.onOff setOn:(BOOL)[[layer objectForKey:@"visible"] boolValue]];
    [cell.onOff setLayerName:[layer objectForKey:@"name"]];
    [cell.onOff addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged ];
    [cell.slider setLayerName:[layer objectForKey:@"name"]];
    [cell.slider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged ];
    return cell;
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *layer = [_opLayers objectAtIndex:indexPath.row];
    AGSLayer *mapLayer = [_mapView mapLayerForName:[layer objectForKey:@"name"]];
    _selectedLayer = mapLayer;
    [self performSegueWithIdentifier:@"layersToDetails" sender:self.navigationController];
}

-(void)switchChanged:(LayerSwitch*)sender{
    NSArray *filtered = [_opLayers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(name LIKE[cd]%@)",sender.layerName]];
    //NSMutableDictionary *layer = [_opLayers objectAtIndex:sender.tag];

    NSMutableDictionary *layer = [filtered objectAtIndex:0];
    [layer setObject:([sender isOn])?@"1":@"0" forKey:@"visible"];
    [SingletonData setLayersJson:_opLayers];
    if (!_mapView) {
        _mapView = [SingletonData getMapView];
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    UITableViewCell *cell = [_layerTableView cellForRowAtIndexPath:indexPath];
    if ([sender isOn]) {

        //[_mapView insertMapLayer:dynLayer withName:[layer objectForKey:@"name"] atIndex:sender.tag + 2];
        
  
        
        NSArray *filteredLayers = [_mapView.mapLayers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(name LIKE[cd]%@)", sender.layerName]];
        if ([filteredLayers count] == 0) {
            NSURL* url = [NSURL URLWithString:[layer objectForKey:@"url"]];
            AGSDynamicMapServiceLayer *dynLayer = [AGSDynamicMapServiceLayer dynamicMapServiceLayerWithURL:url];
            [dynLayer setDpi:96];
            [dynLayer setOpacity:(CGFloat)[[layer objectForKey:@"opacity"] floatValue]];
            [_mapView addMapLayer:dynLayer withName:[layer objectForKey:@"name"]];
            dynLayer.delegate = self;
            cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        }
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [_mapView removeMapLayerWithName:[layer objectForKey:@"name"]];
    }
    [SingletonData setMapView:_mapView];
}

-(void)sliderChanged:(LayerSlider*)sender{
    NSArray *filtered = [_opLayers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(name LIKE[cd]%@)",sender.layerName]];

    NSMutableDictionary *layer = [filtered objectAtIndex:0];
    
    [layer setObject:[NSString stringWithFormat:@"%f", sender.value] forKey:@"opacity"];
    [SingletonData setLayersJson:_opLayers];
    AGSLayer *mapLayer= [_mapView mapLayerForName:[layer objectForKey:@"name"]];
    [mapLayer setOpacity:sender.value];
}

-(void)layerDidLoad:(AGSLayer *)layer
{
    if ([layer isKindOfClass:[AGSDynamicMapServiceLayer class]]) {
        NSMutableArray *visibleLayers = [NSMutableArray array];
        AGSDynamicMapServiceLayer *dLayer = (AGSDynamicMapServiceLayer *)layer;
        for (int i = 0; i < dLayer.mapServiceInfo.layerInfos.count; i++) {
            AGSMapServiceLayerInfo *info = [dLayer.mapServiceInfo.layerInfos objectAtIndex:i];
            if (info.defaultVisibility) {
                [visibleLayers addObject:[NSNumber numberWithInt: (int)info.layerId]];
            }
        }
        dLayer.visibleLayers = visibleLayers;
    }

}

-(void)layer:(AGSLayer *)layer didFailToLoadWithError:(NSError *)error
{
    
}


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"layersToDetails"]){
        if ([segue.destinationViewController respondsToSelector:@selector(setLayer:)]) {
            [segue.destinationViewController performSelector:@selector(setLayer:)
                                                  withObject:_selectedLayer];
        }
    }
}
- (IBAction)closePopover:(id)sender {
    
}

-(void)setMapView:(AGSMapView *)mapView {
    _mapView = mapView;
}

@end
