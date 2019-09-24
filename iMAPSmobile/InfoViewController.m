//
//  InfoViewController.m
//  iMAPSmobile
//
//  Created by Justin Greco on 10/7/13.
//  Copyright (c) 2013 City of Raleigh. All rights reserved.
//

#import "InfoViewController.h"
#import "PhotosViewController.h"
#import "DeedsViewController.h"
#import "MapViewController.h"
#import "TaxViewController.h"
#import "ServicesWebViewController.h"
#import "AddressesViewController.h"
#import "SingletonData.h"

#import "SVProgressHUD.h"


@interface InfoViewController ()

@end

@implementation InfoViewController
@synthesize info = _info, queryTask = _queryTask, query = _query, graphic = _graphic, fields = _fields;

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

}

-(void)getSepticPermits:(NSString*)pin{
    self.queue = [[NSOperationQueue alloc] init];

    NSURL *url = [NSURL URLWithString:@"https://maps.raleighnc.gov/arcgis/rest/services/Environmental/SepticTanks/MapServer/0/query"];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@"json" forKey:@"f"];
    [params setObject:[[@"current_pin = '" stringByAppendingString: pin] stringByAppendingString:@"'"] forKey:@"where"];
    [params setObject:@"PERMIT_NUMBER,CURRENT_PIN" forKey:@"outFields"];

    self.jsonOp = [[AGSJSONRequestOperation alloc] initWithURL:url queryParameters:params];
    self.jsonOp.target = self;
    self.jsonOp.action = @selector(operation:didSucceedWithPermits:);
   // self.jsonOp.errorAction = @selector(operation:didFailWithError:);
    [self.queue addOperation:self.jsonOp];
}

- (void)operation:(NSOperation*)op didSucceedWithPermits:(NSDictionary *)results {
    _permits = [results objectForKey:@"features"];
    if(_permits.count > 0) {
        
    }
}
-(void)initiateQueryTask {
    NSURL* url = [NSURL URLWithString:@"https://maps.raleighnc.gov/ArcGIS/rest/services/Property/Property/MapServer/0"];
    self.queryTask = [[AGSQueryTask alloc] initWithURL:url];
    self.queryTask.delegate = self;
    self.query = [[AGSQuery alloc] init];
}

-(void)setFields {
    self.fields = [NSMutableArray new];
    NSDictionary *account = [_info objectForKey:@"account"];
    NSMutableDictionary *attributes = [account objectForKey:@"attributes"];
    NSArray *fields = [_info objectForKey:@"fields"];
    for (NSMutableDictionary *field in fields) {
        NSString *name = [field objectForKey:@"name" ];
        if ([name isEqualToString: @"OBJECTID"] || [attributes objectForKey:name] == [NSNull null]) {
            
        } else {
            [field setValue: [attributes objectForKey:name] forKey:@"value"];
            [self.fields addObject:field];
        }
    }
    [self.tableView reloadData];

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
    if (@available(iOS 13, *)) {
        if(self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
            self.navigationController.navigationBar.barTintColor = [UIColor blackColor];

        } else {
            self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
        }
    }
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.toolbarHidden = NO;

    //self.findTask = [[AGSFindTask alloc] initWithURL:url];
    //self.findTask.delegate = self;

    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD show];
    //self.findParams = [[AGSFindParameters alloc] init];

    NSDictionary *account = [_info objectForKey:@"account"];
    NSMutableDictionary *attributes = [account objectForKey:@"attributes"];

        
    
    NSString *pin = [attributes objectForKey:@"PIN_NUM"];
    
    [self findProperty:pin];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showProperty:) name:@"showPropertyNotification" object:nil];
    [self getSepticPermits:pin];
   // }
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

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.toolbar.userInteractionEnabled = YES;
    self.navigationController.navigationBar.userInteractionEnabled = YES;
    
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        NSMutableDictionary* dict = [NSMutableDictionary dictionary];
        if ([SingletonData getProperty]) {
            [dict setObject:[SingletonData getProperty] forKey:@"graphic"];
            [[NSNotificationCenter defaultCenter] postNotificationName: @"addGraphicNotification" object: self userInfo: dict];
        }

    }
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
    return [self.fields count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"InfoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil){
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
   // NSDictionary *attributes = [account objectForKey:@"attributes"];

    NSDictionary *field = [self.fields objectAtIndex:indexPath.section];
    NSString *fieldName = [field objectForKey:@"name"];
    cell.textLabel.numberOfLines = 2;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    NSString *fieldType = [field objectForKey:@"type"];
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    
    
    if ([fieldName isEqualToString:@"BLDG_VAL"] || [fieldName isEqualToString:@"LAND_VAL"] || [fieldName isEqualToString:@"TOTAL_VALUE_ASSD"] || [fieldName isEqualToString:@"TOTSALPRICE"]) {
        [formatter  setNumberStyle:NSNumberFormatterCurrencyStyle];
        cell.textLabel.text = [formatter stringFromNumber:[field objectForKey:@"value"]];
    } else if ([fieldType isEqualToString:@"esriFieldTypeDouble"]) {
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        cell.textLabel.text = [formatter stringFromNumber:[field objectForKey:@"value"]];
    } else if ([fieldType isEqualToString:@"esriFieldTypeDate"]) {
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[field objectForKey:@"value"] integerValue]/1000];
        NSDateFormatter *dateformatter=[[NSDateFormatter alloc]init];
        [dateformatter setLocale:[NSLocale currentLocale]];
        [dateformatter setDateFormat:@"M/d/yyyy"];
        NSString *dateString=[dateformatter stringFromDate:date];
        cell.textLabel.text = dateString;
    }  else {
        cell.textLabel.text= [NSString stringWithFormat:@"%@", [field objectForKey:@"value"]];
    }


    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSDictionary *field = [self.fields objectAtIndex:section];
    return [field objectForKey:@"alias"];
}

- (IBAction)returnToSearch:(id)sender {
    [self performSegueWithIdentifier:@"infoToSearch" sender:self];
}
- (IBAction)showPropertyOnMap:(id)sender {
    self.navigationController.toolbar.userInteractionEnabled = NO;

    [self performSegueWithIdentifier:@"infoToMap" sender:self];
}

-(void)findProperty:(NSString*)pin {
    [self initiateQueryTask];
    [self setFields];
    //if (pin == nil) {
        pin = [[[self.info objectForKey:@"account"] objectForKey:@"attributes"] objectForKey:@"PIN_NUM"];
    //}
    //if (pin != nil) {
        self.query.whereClause = [[@"PIN_NUM = '" stringByAppendingString:pin] stringByAppendingString:@"'"];
        self.query.returnGeometry = TRUE;
        [self.queryTask executeWithQuery:self.query];
    //}
}

#pragma mark - AGSFindTaskDelegate
-(void)queryTask:(AGSQueryTask *)queryTask operation:(NSOperation *)op didExecuteWithFeatureSetResult:(AGSFeatureSet *)featureSet {

    self.graphic = [[featureSet features] objectAtIndex:0];
    //self.graphic = result.feature;
    [SingletonData setProperty:self.graphic];
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setObject:self.graphic forKey:@"graphic"];
    [SVProgressHUD dismiss];

    self.navigationController.toolbar.userInteractionEnabled = YES;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        NSMutableDictionary* dict = [NSMutableDictionary dictionary];
        [dict setObject:self.graphic forKey:@"graphic"];
        [[NSNotificationCenter defaultCenter] postNotificationName: @"addGraphicNotification" object: self userInfo: dict];
    }
    
    
    
}

-(void)showProperty: (NSNotification*) notification {

    self.info = notification.userInfo;
    [self.tableView reloadData];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {

    
    [[UIApplication sharedApplication] sendAction:self.splitViewController.displayModeButtonItem.action to:self.splitViewController.displayModeButtonItem.target from:nil forEvent:nil ];
        }
    NSDictionary *account = [_info objectForKey:@"account"];
    NSString *pin = [[account objectForKey:@"attributes"] objectForKey:@"PIN_NUM"];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self findProperty:pin];
        if (self.splitViewController.displayMode == UISplitViewControllerDisplayModeAllVisible) {
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showProperty:) name:@"showPropertyNotification" object:nil];
            [self getSepticPermits:pin];
        }
    }
}

- (IBAction)showActionSheet:(UIBarButtonItem *)sender {

   // if ([UIAlertController class]) {
        UIAlertControllerStyle style = UIAlertControllerStyleActionSheet;
        UIDeviceOrientation orient = [UIDevice currentDevice].orientation;
        if (UIDeviceOrientationIsLandscape(orient)) {
            style = UIAlertControllerStyleAlert;
        }
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"More Information" message:nil preferredStyle:style];
        UIAlertAction* photos = [UIAlertAction actionWithTitle:NSLocalizedString(@"Photos", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self performSegueWithIdentifier:@"infoToPhotos" sender:self];
        }];
        UIAlertAction* deeds = [UIAlertAction actionWithTitle:NSLocalizedString(@"Deeds & Plats", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self performSegueWithIdentifier:@"infoToDeeds" sender:self];
        }];
        UIAlertAction* taxes = [UIAlertAction actionWithTitle:NSLocalizedString(@"Tax Info", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self performSegueWithIdentifier:@"infoToTaxes" sender:self];
        }];
        UIAlertAction* services = [UIAlertAction actionWithTitle:NSLocalizedString(@"Services", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self performSegueWithIdentifier:@"infoToServices" sender:self];
        }];
        UIAlertAction* addresses = [UIAlertAction actionWithTitle:NSLocalizedString(@"Addresses", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self performSegueWithIdentifier:@"infoToAddresses" sender:self];
        }];
        
        UIAlertAction* septic = [UIAlertAction actionWithTitle:NSLocalizedString(@"Septic Permits", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            //[self performSegueWithIdentifier:@"infoToSeptic" sender:self];
            UIApplication *application = [UIApplication sharedApplication];
            NSString *urlString = [@"https://maps.wakegov.com/septic/index.html#/?pin=" stringByAppendingString: [[[self.info objectForKey:@"account"] objectForKey:@"attributes"] objectForKey:@"PIN_NUM"]];

            NSURL *URL = [NSURL URLWithString:urlString];
            [application openURL:URL options:@{} completionHandler:nil];


        }];
        UIAlertAction* cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];

        [alert addAction:photos];
        [alert addAction:deeds];
        [alert addAction:taxes];
        [alert addAction:services];
        [alert addAction:addresses];
        if (self.permits.count > 0) {
            [alert addAction:septic];
        }
        [alert addAction:cancel];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [alert.popoverPresentationController setBarButtonItem:sender];
        }
        [self presentViewController:alert animated:YES completion:nil];
        
}

-(void)findTask:(AGSFindTask *)findTask operation:(NSOperation *)op didFailWithError:(NSError *)error{
    self.navigationController.toolbar.userInteractionEnabled = YES;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSDictionary *account = [_info objectForKey:@"account"];
    NSString *reid = [[account objectForKey:@"attributes"] objectForKey:@"REID"];
    NSString *pin =  [[account objectForKey:@"attributes"] objectForKey:@"PIN_NUM"];
    if ([[segue identifier] isEqualToString:@"infoToMap"]){
        
        [segue.destinationViewController performSelector:@selector(setProperty:)
                                              withObject:self.graphic];
    } else if ([[segue identifier] isEqualToString:@"infoToTaxes"]){
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            UINavigationController *nav = (UINavigationController*)segue.destinationViewController;
            TaxViewController *vc = [nav.childViewControllers objectAtIndex:0];
            
            
            [vc performSelector:@selector(setReid:)
                     withObject:reid];
        } else {
            [segue.destinationViewController performSelector:@selector(setReid:)withObject:reid];
        }

        
    } else if ([[segue identifier] isEqualToString:@"infoToPhotos"]){
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            UINavigationController *nav = (UINavigationController*)segue.destinationViewController;
            PhotosViewController *vc = [nav.childViewControllers objectAtIndex:0];
            [vc performSelector:@selector(setReid:)
                     withObject:reid];
        } else {
            [segue.destinationViewController performSelector:@selector(setReid:)withObject:reid];
        }

    }
    else if ([[segue identifier] isEqualToString:@"infoToDeeds"]){
        [segue.destinationViewController performSelector:@selector(setReid:)
                                              withObject:reid];
    } else if ([[segue identifier] isEqualToString:@"infoToServices"]){
        [segue.destinationViewController performSelector:@selector(setPin:) withObject:pin];
    } else if ([[segue identifier] isEqualToString:@"infoToAddresses"]){
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setValue:pin forKey:@"pin"];
        [params setValue:reid forKey:@"reid"];
        [segue.destinationViewController performSelector:@selector(setParams:) withObject:params];
    } else if ([[segue identifier] isEqualToString:@"infoToSeptic"]){
        [segue.destinationViewController performSelector:@selector(setPermits:) withObject:self.permits];
    }
}


@end
