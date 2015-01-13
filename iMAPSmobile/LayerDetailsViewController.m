//
//  LayerDetailsViewController.m
//  iMAPSmobile
//
//  Created by Justin Greco on 10/9/13.
//  Copyright (c) 2013 City of Raleigh. All rights reserved.
//

#import "LayerDetailsViewController.h"
#import "LayerDetailCell.h"
#import "SVProgressHUD.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"


@interface LayerDetailsViewController ()

@end

@implementation LayerDetailsViewController
@synthesize layerInfos = _layerInfos;
@synthesize layer = _layer;
@synthesize mapServiceInfo = _mapServiceInfo;
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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.toolbar.userInteractionEnabled = YES;
    self.navigationController.toolbarHidden = NO;
    self.navigationController.navigationBar.userInteractionEnabled = YES;
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Layer Details Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
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
    return [_layerInfos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"LayerDetailCell";
    LayerDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    AGSMapServiceLayerInfo* layerInfo = (AGSMapServiceLayerInfo*)[_layerInfos objectAtIndex:indexPath.row];
    cell.label.text = layerInfo.name;
    //if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7) {
        CGRect frame = cell.label.frame;
        frame.origin.x = 105;
        [cell.label setFrame:frame];
    }
    
    if ([_layer isKindOfClass:[AGSDynamicMapServiceLayer class]]) {
        [cell.onOff setLayerId:[NSNumber numberWithInt:(int)layerInfo.layerId]];
        AGSDynamicMapServiceLayer *dLayer = (AGSDynamicMapServiceLayer*)_layer;
        if ([dLayer.visibleLayers containsObject:[NSNumber numberWithInt:(int)layerInfo.layerId]])
        {
            [cell.onOff setOn:YES];
        } else {
            [cell.onOff setOn:NO];
        }
    }
    
    return cell;
}

- (IBAction)layerSwitchValueChange:(LayerDetailSwitch *)sender {
        if ([_layer isKindOfClass:[AGSDynamicMapServiceLayer class]]) {

            AGSDynamicMapServiceLayer *dLayer = (AGSDynamicMapServiceLayer*)_layer;
            NSMutableArray *visibleLayers = [[NSMutableArray alloc] initWithArray:dLayer.visibleLayers copyItems:YES];

            if (sender.isOn) {
                [visibleLayers addObject:sender.layerId];
            } else {
                [visibleLayers removeObject:sender.layerId];
            }
            dLayer.visibleLayers = visibleLayers;
        }
}



#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"detailsToLegend"]){
        if ([segue.destinationViewController respondsToSelector:@selector(setLayerInfos:)]) {
            [segue.destinationViewController performSelector:@selector(setLayerInfos:)
                                                  withObject:_layerInfos];
        }
    }
}



-(void)setLayer:(AGSLayer*)layer
{
    _layer = layer;
    if ([layer isKindOfClass:[AGSDynamicMapServiceLayer class]]) {
        AGSDynamicMapServiceLayer *dLayer = (AGSDynamicMapServiceLayer*)layer;
        dLayer.mapServiceInfo.delegate = self;
        _mapServiceInfo = dLayer.mapServiceInfo;
        _layerInfos = _mapServiceInfo.layerInfos;
        //[dLayer.mapServiceInfo retrieveLegendInfo];
    }
}

- (IBAction)showLegend:(id)sender {
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    [_mapServiceInfo retrieveLegendInfo];
}

-(void)mapServiceInfo:(AGSMapServiceInfo *)mapServiceInfo operationDidRetrieveLegendInfo:(NSOperation *)op
{
    [SVProgressHUD dismiss];
    _layerInfos = mapServiceInfo.layerInfos;
    [self performSegueWithIdentifier:@"detailsToLegend" sender:self];

}

-(void)mapServiceInfo:(AGSMapServiceInfo *)mapServiceInfo operation:(NSOperation *)op didFailToRetrieveLegendInfoWithError:(NSError *)error
{
    [SVProgressHUD dismiss];
}

@end
