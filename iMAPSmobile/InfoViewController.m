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
    NSDictionary *account = [_info objectForKey:@"account"];
    switch (buttonIndex) {
        case 0://photos
            [self performSegueWithIdentifier:@"infoToPhotos" sender:self];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Info Events" action:@"Viewed Additional Info" label:@"Photos" value:nil] build]];
            break;
        case 1://deeds
            [self performSegueWithIdentifier:@"infoToDeeds" sender:self];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Info Events" action:@"Viewed Additional Info" label:@"Deeds" value:nil] build]];
            break;
        case 2://taxInfo
            [self performSegueWithIdentifier:@"infoToTaxes" sender:self];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Info Events" action:@"Viewed Additional Info" label:@"Real Estate" value:nil] build]];
            break;
        case 3://services
            [self performSegueWithIdentifier:@"infoToServices" sender:self];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Info Events" action:@"Viewed Additional Info" label:@"Services" value:nil] build]];
            break;
        case 4://addresses
            [self performSegueWithIdentifier:@"infoToAddresses" sender:self];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Info Events" action:@"Viewed Additional Info" label:@"Addresses" value:nil] build]];
            break;
        case 5://crime
            if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Crime Activity"]) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://mapstest.raleighnc.gov/crime/?pin=%@",[account objectForKey:@"pin"]]]];
                [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Info Events" action:@"Viewed Additional Info" label:@"Crime" value:nil] build]];
            }

        default:
            break;
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
    }
}
- (IBAction)showActionSheet:(id)sender {
    UIActionSheet *actionSheet = nil;
    //NSDictionary *account = [_info objectForKey:@"account"];
    //NSString *city = [account objectForKey:@"city"];
    /*if ([city.uppercaseString isEqualToString:@"RALEIGH"]) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"More Information" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Photos",@"Deeds & Plats",@"Tax Info", @"Services", @"Addresses", @"Crime Activity", nil];
    } else {*/
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"More Information" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Photos",@"Deeds & Plats",@"Tax Info", @"Services", @"Addresses", nil];
    //}
    actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1;
    [actionSheet showInView:self.view];
}


@end
