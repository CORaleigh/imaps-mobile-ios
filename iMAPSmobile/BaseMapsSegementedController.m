//
//  BaseMapsSegementedController.m
//  iMAPSmobile
//
//  Created by Justin Greco on 12/13/13.
//  Copyright (c) 2013 City of Raleigh. All rights reserved.
//

#import "BaseMapsSegementedController.h"
#import "SingletonData.h"
#import "Reachability.h"

@interface BaseMapsSegementedController ()

@end

@implementation BaseMapsSegementedController
@synthesize jsonOp = _jsonOp, queue = _queue, baseLayers = _baseLayers, imageLayers = _imageLayers, picker = _picker, labelSwitch = _labelSwitch, segment = _segment, raleighBounds = _raleighBounds, label = _label;
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
    } else {
        [self.view setBackgroundColor:[UIColor whiteColor]];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    if ([SingletonData getCurrentBaseType]) {
        [self.segment setSelectedSegmentIndex:([[SingletonData getCurrentBaseType] isEqualToString:@"base"]) ? 0 : 1];
    }

    NSString *json = @"{\"rings\": [[[2137500.00002,792499.999837],[2152499.99988,792499.999837],[2152499.99988,789999.999916],[2155000.00013,789999.999916],[2155000.00013,767499.999969],[2155000.00013,765000.000047],[2157500.00005,765000.000047],[2157500.00005,759999.999877],[2155000.00013,759999.999877],[2155000.00013,757499.999956],[2147500.00003,757499.999956],[2147500.00003,755000.000034],[2149999.99996,755000.000034],[2149999.99996,745000.000021],[2147500.00003,745000.000021],[2147500.00003,742500.0001],[2139999.99994,742500.0001],[2139999.99994,727499.999916],[2142499.99986,727499.999916],[2142499.99986,724999.999995],[2145000.00011,724999.999995],[2145000.00011,720000.000153],[2149999.99996,720000.000153],[2149999.99996,717499.999903],[2147500.00003,717499.999903],[2147500.00003,714999.999982],[2145000.00011,714999.999982],[2145000.00011,710000.00014],[2132499.99985,710000.00014],[2132499.99985,712500.000061],[2125000.00009,712500.000061],[2125000.00009,714999.999982],[2122499.99984,714999.999982],[2122499.99984,720000.000153],[2112500.00015,720000.000153],[2112500.00015,717499.999903],[2102500.00014,717499.999903],[2102500.00014,720000.000153],[2099999.99989,720000.000153],[2099999.99989,717499.999903],[2095000.00005,717499.999903],[2095000.00005,714999.999982],[2087499.99996,714999.999982],[2087499.99996,717499.999903],[2085000.00003,717499.999903],[2085000.00003,720000.000153],[2082500.00011,720000.000153],[2082500.00011,722500.000074],[2079999.99986,722500.000074],[2079999.99986,724999.999995],[2077499.99994,724999.999995],[2077499.99994,732500.000087],[2075000.00002,732500.000087],[2075000.00002,737499.999929],[2072500.0001,737499.999929],[2072500.0001,745000.000021],[2075000.00002,745000.000021],[2075000.00002,752500.000113],[2072500.0001,752500.000113],[2072500.0001,755000.000034],[2069999.99985,755000.000034],[2069999.99985,759999.999877],[2065000.00001,759999.999877],[2065000.00001,765000.000047],[2062500.00009,765000.000047],[2062500.00009,767499.999969],[2065000.00001,767499.999969],[2065000.00001,769999.99989],[2067499.99993,769999.99989],[2067499.99993,779999.999903],[2065000.00001,779999.999903],[2065000.00001,777499.999982],[2062500.00009,777499.999982],[2062500.00009,775000.000061],[2057499.99992,775000.000061],[2057499.99992,779999.999903],[2052500.00007,779999.999903],[2052500.00007,789999.999916],[2055000,789999.999916],[2055000,797500.000008],[2067499.99993,797500.000008],[2067499.99993,795000.000087],[2072500.0001,795000.000087],[2072500.0001,797500.000008],[2077499.99994,797500.000008],[2077499.99994,789999.999916],[2082500.00011,789999.999916],[2082500.00011,787499.999995],[2087499.99996,787499.999995],[2087499.99996,789999.999916],[2092500.00013,789999.999916],[2092500.00013,787499.999995],[2099999.99989,787499.999995],[2099999.99989,795000.000087],[2122499.99984,795000.000087],[2122499.99984,799999.999929],[2125000.00009,799999.999929],[2125000.00009,802499.99985],[2127500.00001,802499.99985],[2127500.00001,809999.999942],[2137500.00002,809999.999942]]],\"spatialReference\": {\"wkid\": 2246}}";
    NSDictionary *jsonDict = [json ags_JSONValue];
    self.raleighBounds = [AGSPolygon polygonWithJSON:jsonDict];

    
    self.queue = [[NSOperationQueue alloc] init];

    [self testNetworkConnection];
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.toolbarHidden = YES;
    

    
    if ([SingletonData getBaseLayer]) {
        NSDictionary *baseLayer = [SingletonData getBaseLayer];
        [self enableLabels:![[baseLayer objectForKey:@"fusedLabels"] boolValue]];
    }

}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    self.jsonOp.target = self;
    self.jsonOp.action = @selector(operation:didSucceedWithReponse:);
    self.jsonOp.errorAction = @selector(operation:didFailWithResponse:);
    [self.queue addOperation:self.jsonOp];
}


- (void)operation:(NSOperation*)op didSucceedWithReponse:(NSDictionary *)results {
    _baseLayers = [results objectForKey:@"BaseMapLayers"];
    _imageLayers = [results objectForKey:@"ImageLayers"];
    
    NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:NO];
    [_imageLayers sortUsingDescriptors:[NSArray arrayWithObjects:nameDescriptor, nil]];
    [self.picker reloadAllComponents];

    
    switch (self.segment.selectedSegmentIndex) {
        case 0:
            [self.picker selectRow:[SingletonData getBaseIndex] inComponent:0 animated:NO];
            break;
        case 1:
             [self.picker selectRow:[SingletonData getAerialIndex] inComponent:0 animated:NO];
            break;
            
        default:
            break;
    }
}

- (void)operation:(NSOperation*)op didFailWithResponse:(NSError *)error {
    
}


-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    AGSMapView *map = [SingletonData getMapView];
    switch (self.segment.selectedSegmentIndex) {
        case 0:
            return [_baseLayers count];
            
            break;
        case 1:

            if (![self.raleighBounds containsPoint:[map.visibleAreaEnvelope center]]) {
                NSArray *filtered = [_imageLayers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"countywide == YES"]];
                return filtered.count;
                
            } else {
                return _imageLayers.count;
            }
            return [_imageLayers count];
            break;
        default:
            return 0;
            break;
    }
    
    
    

}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    AGSMapView *map = [SingletonData getMapView];

    switch (self.segment.selectedSegmentIndex) {
        case 0:
            
            return [[_baseLayers objectAtIndex:row]objectForKey:@"name"];
            
            break;
        case 1:
            if (![self.raleighBounds containsPoint:[map.visibleAreaEnvelope center]]) {
                NSArray *filtered = [_imageLayers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"countywide == YES"]];
                return [[filtered objectAtIndex:row]objectForKey:@"name"];

            } else {
                return [[_imageLayers objectAtIndex:row]objectForKey:@"name"];
               
            }
            
            break;
        default:
            return @"";
            break;
    }
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    switch (self.segment.selectedSegmentIndex) {
        case 0:
            [SingletonData setBaseIndex:row];
            [self setBaseMapLayer:[_baseLayers objectAtIndex:row]];
            [self enableLabels:![[[_baseLayers objectAtIndex:row] objectForKey:@"fusedLabels"] boolValue]];

            break;
        case 1:
            [SingletonData setAerialIndex:row];
            AGSMapView *map = [SingletonData getMapView];
            if (![self.raleighBounds containsPoint:[map.visibleAreaEnvelope center]]) {
                NSArray *filtered = [_imageLayers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"countywide == YES"]];
                [self setBaseMapLayer:[filtered objectAtIndex:row]];
                
            } else {
                [self setBaseMapLayer:[_imageLayers objectAtIndex:row]];
                
            }
            
            [self enableLabels:![[[_imageLayers objectAtIndex:row] objectForKey:@"fusedLabels"] boolValue]];

            break;
    }
}

-(void)enableLabels:(BOOL)enabled {
    self.label.enabled = enabled;
    self.labelSwitch.enabled = enabled;
    AGSLayer *layer = [SingletonData getLabels];
    
    if ([SingletonData getLabels] && enabled) {
        self.labelSwitch.on = YES;
        [layer setVisible:YES];
    }
    if (!enabled) {
        AGSLayer *layer = [SingletonData getLabels];
        self.labelSwitch.on = NO;
        [layer setVisible:NO];
    }
}


-(void)setBaseMapLayer:(NSDictionary *) layer{
    [SingletonData setBaseLayer:layer];
    if (!_mapView) {
        _mapView = [SingletonData getMapView];
    }
    NSString *type = [layer objectForKey:@"type"];
    NSURL *url = [NSURL URLWithString:[layer objectForKey:@"url"]];
    if ([type isEqualToString:@"tiled"]) {
        _layer = [AGSTiledMapServiceLayer tiledMapServiceLayerWithURL:url];
    } else if ([type isEqualToString:@"dynamic"]) {
        _layer = [AGSDynamicMapServiceLayer dynamicMapServiceLayerWithURL:url];
    } else if ([type isEqualToString:@"image"]) {
        _layer = [AGSImageServiceLayer imageServiceLayerWithURL:url];
    }
    [_layer setName:[layer objectForKey:@"name"]];
    _layer.delegate = self;
    [_mapView removeMapLayer:_mapView.baseLayer];
    [_mapView insertMapLayer:_layer atIndex:0];
    
    
}

- (IBAction)segmentChanged:(id)sender {
    [self.picker reloadAllComponents];
    
    [self.picker selectRow:(self.segment.selectedSegmentIndex == 0) ? [SingletonData getBaseIndex]:[SingletonData getAerialIndex] inComponent:0 animated:NO];
    
    NSUInteger row = [self.picker selectedRowInComponent:0];

    
    [SingletonData setCurrentBaseType:(self.segment.selectedSegmentIndex == 0)?@"base":@"aerial"];
    switch (self.segment.selectedSegmentIndex) {
        case 0:
            [SingletonData setBaseIndex:row];
            [self setBaseMapLayer:[_baseLayers objectAtIndex:row]];
            [self enableLabels:![[[_baseLayers objectAtIndex:row] objectForKey:@"fusedLabels"] boolValue]];

            break;
        case 1:
            [SingletonData setAerialIndex:row];
            AGSMapView *map = [SingletonData getMapView];
            if (![self.raleighBounds containsPoint:[map.visibleAreaEnvelope center]]) {
                NSArray *filtered = [_imageLayers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"countywide == YES"]];
                [self setBaseMapLayer:[filtered objectAtIndex:row]];
                
            } else {
                [self setBaseMapLayer:[_imageLayers objectAtIndex:row]];
                
            }
            [self enableLabels:![[[_imageLayers objectAtIndex:row] objectForKey:@"fusedLabels"] boolValue]];

            break;
    }
}
- (IBAction)labelsToggled:(UISwitch*)sender {
    if ([SingletonData getLabels]) {
        AGSLayer *layer = [SingletonData getLabels];
        [layer setVisible:_labelSwitch.isOn];
    }
}
@end
