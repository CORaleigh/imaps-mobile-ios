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
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"


@interface InfoViewController ()

@end

@implementation InfoViewController
@synthesize info = _info, findParams = _findParams, findTask = _findTask, graphic = _graphic;

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

    NSURL* url = [NSURL URLWithString:@"http://maps.raleighnc.gov/ArcGIS/rest/services/Parcels/MapServer"];
    self.findTask = [[AGSFindTask alloc] initWithURL:url];
    self.findTask.delegate = self;
    self.findParams = [[AGSFindParameters alloc] init];
    NSDictionary *account = [_info objectForKey:@"account"];
    NSString *pin = [account objectForKey:@"pin"];
    [self findProperty:pin];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showProperty:) name:@"showPropertyNotification" object:nil];
    [self getSepticPermits:pin];

}

-(void)getSepticPermits:(NSString*)pin{
    self.queue = [[NSOperationQueue alloc] init];
    NSURL *url = [NSURL URLWithString:@"http://maps.raleighnc.gov/arcgis/rest/services/Parcels/MapServer/exts/PropertySOE/SepticPermits"];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@"jsonp" forKey:@"f"];
    [params setObject:pin forKey:@"pin"];
    self.jsonOp = [[AGSJSONRequestOperation alloc] initWithURL:url queryParameters:params];
    self.jsonOp.target = self;
    self.jsonOp.action = @selector(operation:didSucceedWithPermits:);
   // self.jsonOp.errorAction = @selector(operation:didFailWithError:);
    [self.queue addOperation:self.jsonOp];
}

- (void)operation:(NSOperation*)op didSucceedWithPermits:(NSDictionary *)results {
    _permits = [results objectForKey:@"SepticPermits"];
    if(_permits.count > 0) {
        
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.toolbarHidden = NO;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.toolbar.userInteractionEnabled = YES;
    self.navigationController.navigationBar.userInteractionEnabled = YES;
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Info Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        NSMutableDictionary* dict = [NSMutableDictionary dictionary];
        [dict setObject:[SingletonData getProperty] forKey:@"graphic"];
        [[NSNotificationCenter defaultCenter] postNotificationName: @"addGraphicNotification" object: self userInfo: dict];
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
    NSMutableArray *fields = [_info objectForKey:@"fields"];
    return [fields count];
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
    
    NSDictionary *account = [_info objectForKey:@"account"];
    NSMutableArray *fields = [_info objectForKey:@"fields"];
    NSDictionary *field = [fields objectAtIndex:indexPath.section];
    NSString *fieldName = [field objectForKey:@"field"];
    cell.textLabel.numberOfLines = 2;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    NSString *fieldType = [field objectForKey:@"type"];
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    
    
    if ([fieldType isEqualToString:@"currency"]) {
        [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        cell.textLabel.text = [formatter stringFromNumber:[account objectForKey:fieldName]];
    } else if ([fieldType isEqualToString:@"number"]) {
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        cell.textLabel.text = [formatter stringFromNumber:[account objectForKey:fieldName]];
    } else {
        cell.textLabel.text= [NSString stringWithFormat:@"%@", [account objectForKey:fieldName]];
    }


    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSMutableArray *fields = [_info objectForKey:@"fields"];
    NSDictionary *field = [fields objectAtIndex:section];
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
    self.findParams.layerIds = [NSArray arrayWithObjects:@"0", @"1", nil];
    self.findParams.searchText = pin;
    self.findParams.searchFields = [NSArray arrayWithObjects:@"PIN_NUM", nil];
    self.findParams.returnGeometry = TRUE;
    [self.findTask executeWithParameters:self.findParams];

}

#pragma mark - AGSFindTaskDelegate
-(void)findTask:(AGSFindTask *)findTask operation:(NSOperation *)op didExecuteWithFindResults:(NSArray *)results {
    AGSFindResult *result = [results objectAtIndex:0];
    self.graphic = result.feature;
    [SingletonData setProperty:self.graphic];
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setObject:self.graphic forKey:@"graphic"];
    
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
    NSDictionary *account = [_info objectForKey:@"account"];
    NSString *pin = [account objectForKey:@"pin"];
    [self findProperty:pin];
}

#pragma mark - UIActionSheetDelegate methods
-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
    id tracker = [[GAI sharedInstance] defaultTracker];
//    switch (buttonIndex) {
//        case 0://photos
//            [self performSegueWithIdentifier:@"infoToPhotos" sender:self];
//            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Info Events" action:@"Viewed Additional Info" label:@"Photos" value:nil] build]];
//            break;
//        case 1://deeds
//            [self performSegueWithIdentifier:@"infoToDeeds" sender:self];
//            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Info Events" action:@"Viewed Additional Info" label:@"Deeds" value:nil] build]];
//            break;
//        case 2://taxInfo
//            [self performSegueWithIdentifier:@"infoToTaxes" sender:self];
//            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Info Events" action:@"Viewed Additional Info" label:@"Real Estate" value:nil] build]];
//            break;
//        case 3://services
//            [self performSegueWithIdentifier:@"infoToServices" sender:self];
//            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Info Events" action:@"Viewed Additional Info" label:@"Services" value:nil] build]];
//            break;
//        case 4://addresses
//            [self performSegueWithIdentifier:@"infoToAddresses" sender:self];
//            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Info Events" action:@"Viewed Additional Info" label:@"Addresses" value:nil] build]];
//            break;
//        case 5://crime
//            if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Crime Activity"]) {
//                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://mapstest.raleighnc.gov/crime/?pin=%@",[account objectForKey:@"pin"]]]];
//                [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Info Events" action:@"Viewed Additional Info" label:@"Crime" value:nil] build]];
//            }
//
//        default:
//            break;
            if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Photos"]) {
                [self performSegueWithIdentifier:@"infoToPhotos" sender:self];
                [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Info Events" action:@"Viewed Additional Info" label:@"Photos" value:nil] build]];
            }
            else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Deeds & Plats"]) {
                [self performSegueWithIdentifier:@"infoToDeeds" sender:self];
                [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Info Events" action:@"Viewed Additional Info" label:@"Deeds" value:nil] build]];
            }
            else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Tax Info"]) {
                [self performSegueWithIdentifier:@"infoToTaxes" sender:self];
                [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Info Events" action:@"Viewed Additional Info" label:@"Real Estate" value:nil] build]];
            }
            else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Services"]) {
                [self performSegueWithIdentifier:@"infoToServices" sender:self];
                [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Info Events" action:@"Viewed Additional Info" label:@"Services" value:nil] build]];
            }
            else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Addresses"]) {
                [self performSegueWithIdentifier:@"infoToAddresses" sender:self];
                [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Info Events" action:@"Viewed Additional Info" label:@"Addresses" value:nil] build]];
            }
            else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Septic Permits"]) {
                [self performSegueWithIdentifier:@"infoToSeptic" sender:self];
                [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Info Events" action:@"Viewed Additional Info" label:@"Septic Permits" value:nil] build]];
            }
    
   // }
}
- (IBAction)showActionSheet:(id)sender {
    id tracker = [[GAI sharedInstance] defaultTracker];

    if ([UIAlertController class]) {
        UIAlertControllerStyle style = UIAlertControllerStyleActionSheet;
        UIDeviceOrientation orient = [UIDevice currentDevice].orientation;
        if (UIDeviceOrientationIsLandscape(orient)) {
            style = UIAlertControllerStyleAlert;
        }
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"More Information" message:nil preferredStyle:style];
        UIAlertAction* photos = [UIAlertAction actionWithTitle:@"Photos" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self performSegueWithIdentifier:@"infoToPhotos" sender:self];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Info Events" action:@"Viewed Additional Info" label:@"Photos" value:nil] build]];
        }];
        UIAlertAction* deeds = [UIAlertAction actionWithTitle:@"Deeds & Plats" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self performSegueWithIdentifier:@"infoToDeeds" sender:self];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Info Events" action:@"Viewed Additional Info" label:@"Deeds" value:nil] build]];
        }];
        UIAlertAction* taxes = [UIAlertAction actionWithTitle:@"Tax Info" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self performSegueWithIdentifier:@"infoToTaxes" sender:self];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Info Events" action:@"Viewed Additional Info" label:@"Real Estate" value:nil] build]];
        }];
        UIAlertAction* services = [UIAlertAction actionWithTitle:@"Services" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self performSegueWithIdentifier:@"infoToServices" sender:self];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Info Events" action:@"Viewed Additional Info" label:@"Services" value:nil] build]];
        }];
        UIAlertAction* addresses = [UIAlertAction actionWithTitle:@"Addresses" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self performSegueWithIdentifier:@"infoToAddresses" sender:self];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Info Events" action:@"Viewed Additional Info" label:@"Addresses" value:nil] build]];
        }];
        
        UIAlertAction* septic = [UIAlertAction actionWithTitle:@"Septic Permits" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self performSegueWithIdentifier:@"infoToSeptic" sender:self];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Info Events" action:@"Viewed Additional Info" label:@"Septic Permits" value:nil] build]];
        }];
        UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
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
        [self presentViewController:alert animated:YES completion:nil];
        
    } else {
        UIActionSheet *actionSheet = nil;
        //NSDictionary *account = [_info objectForKey:@"account"];
        //NSString *city = [account objectForKey:@"city"];
        /*if ([city.uppercaseString isEqualToString:@"RALEIGH"]) {
         actionSheet = [[UIActionSheet alloc] initWithTitle:@"More Information" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Photos",@"Deeds & Plats",@"Tax Info", @"Services", @"Addresses", @"Crime Activity", nil];
         } else {*/
        
        if (self.permits.count == 0) {
            actionSheet = [[UIActionSheet alloc] initWithTitle:@"More Information" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Photos",@"Deeds & Plats",@"Tax Info", @"Services", @"Addresses", nil];
        } else {
            actionSheet = [[UIActionSheet alloc] initWithTitle:@"More Information" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Photos",@"Deeds & Plats",@"Tax Info", @"Services", @"Addresses",@"Septic Permits", nil];
        }
        
        //}
        actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1;
        [actionSheet showInView:self.view];
    }
}

-(void)findTask:(AGSFindTask *)findTask operation:(NSOperation *)op didFailWithError:(NSError *)error{
    self.navigationController.toolbar.userInteractionEnabled = YES;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSDictionary *account = [_info objectForKey:@"account"];
    NSString *reid = [account objectForKey:@"reid"];
    NSString *pin = [account objectForKey:@"pin"];
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
