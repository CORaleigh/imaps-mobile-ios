//
//  SearchController.m
//  iMAPSmobile
//
//  Creatared by Justin Greco on 10/3/13.
//  Copyright (c) 2013 City of Raleigh. All rights reserved.
//

#import "SearchController.h"
#import "MapViewController.h"
#import "ResultsViewController.h"
#import "InfoViewController.h"
#import "SVProgressHUD.h"

@interface SearchController ()

@end

@implementation SearchController

@synthesize searchBar = _searchBar;
@synthesize jsonOp = _jsonOp;
@synthesize queue = _queue;
@synthesize tableView = _tableView;
@synthesize suggestionArray = _suggestionArray;
@synthesize findTask = _findTask, findParams = _findParams, findResult = _findResult, results = _results, actionSheet = _actionSheet, type = type, fields = _fields;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    

    
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.toolbarHidden = NO;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.toolbar.translucent = NO;
    self.queue = [[NSOperationQueue alloc] init];
    self.searchBar.placeholder = @"Enter an address";
    self.type = @"Address";
    NSURL* url = [NSURL URLWithString:@"http://maps.raleighnc.gov/ArcGIS/rest/services/Parcels/MapServer"];
    self.findTask = [[AGSFindTask alloc] initWithURL:url];
    self.findTask.delegate = self;
    self.findParams = [[AGSFindParameters alloc] init];
    
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.toolbarHidden = NO;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.toolbar.translucent = NO;

}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.toolbar.userInteractionEnabled = YES;
    self.navigationController.navigationBar.userInteractionEnabled = YES;
    self.screenName = @"Search Screen";

}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.toolbar.translucent = YES;
    self.navigationItem.title = @"Search";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)showActionSheet:(id)sender {
    if ([UIAlertController class]) {
        UIAlertControllerStyle style = UIAlertControllerStyleActionSheet;
        UIDeviceOrientation orient = [UIDevice currentDevice].orientation;
        if (UIDeviceOrientationIsLandscape(orient)) {
            style = UIAlertControllerStyleAlert;
        }
        self.alertController = [UIAlertController alertControllerWithTitle:@"Search By" message:nil preferredStyle: style];
        UIAlertAction* address = [UIAlertAction actionWithTitle:@"Address" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            self.type = action.title;
            self.searchBar.placeholder = @"Enter an address";
            self.searchBar.keyboardType = UIKeyboardTypeDefault;
        }];
        UIAlertAction* owner = [UIAlertAction actionWithTitle:@"Owner" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            self.type = action.title;
            self.searchBar.placeholder = @"Enter an owner name";
            self.searchBar.keyboardType = UIKeyboardTypeDefault;
        }];
        UIAlertAction* pin = [UIAlertAction actionWithTitle:@"PIN" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            self.type = action.title;
            self.searchBar.placeholder = @"Enter a PIN number";
            self.searchBar.keyboardType = UIKeyboardTypeNumberPad;
        }];
        UIAlertAction* reid = [UIAlertAction actionWithTitle:@"REID" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            self.type = action.title;
            self.searchBar.placeholder = @"Enter a real estate ID";
            self.searchBar.keyboardType = UIKeyboardTypeNumberPad;
        }];
        UIAlertAction* street = [UIAlertAction actionWithTitle:@"Street Name" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            self.type = action.title;
            self.searchBar.placeholder = @"Enter a street name";
            self.searchBar.keyboardType = UIKeyboardTypeDefault;
        }];
        UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [self.alertController dismissViewControllerAnimated:YES completion:nil];
        }];
        [self.alertController addAction:address];
        [self.alertController addAction:owner];
        [self.alertController addAction:pin];
        [self.alertController addAction:reid];
        [self.alertController addAction:street];
        [self.alertController addAction:cancel];
        [self presentViewController:self.alertController animated:YES completion:nil];
        
    } else {
            self.actionSheet = [[UIActionSheet alloc] initWithTitle:@"Search By" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Address",@"Owner",@"PIN", @"REID", @"Street Name", nil];
            self.actionSheet.cancelButtonIndex = self.actionSheet.numberOfButtons - 1;
        
            [self.actionSheet showInView:self.view];
    }

    
}
- (IBAction)showMap:(id)sender {
    [self performSegueWithIdentifier:@"searchToMap" sender:self];}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    self.type = title;
    switch (buttonIndex) {
        case 0:
            self.searchBar.placeholder = @"Enter an address";
            self.searchBar.keyboardType = UIKeyboardTypeDefault;
            break;
        case 1:
            self.searchBar.placeholder = @"Enter an owner name";
            self.searchBar.keyboardType = UIKeyboardTypeDefault;
            break;
        case 2:
            self.searchBar.placeholder = @"Enter a PIN number";
            self.searchBar.keyboardType = UIKeyboardTypeNumberPad;
            break;
        case 3:
            self.searchBar.placeholder = @"Enter a real estate ID";
            self.searchBar.keyboardType = UIKeyboardTypeNumberPad;
            break;
        case 4:
            self.searchBar.placeholder = @"Enter a street name";
            self.searchBar.keyboardType = UIKeyboardTypeDefault;
            break;
        default:
            break;
    }
}

#pragma mark - UITableViewDataSourceMethods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _suggestionArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil){
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text=[_suggestionArray objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark - UITableViewDeletegate Methods


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSObject *selection = [_suggestionArray objectAtIndex:indexPath.row];
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:selection];
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setObject:@"jsonp" forKey:@"f"];
    [params setObject:self.type forKey:@"type"];
    [params setObject:values forKey:@"values"];
        NSURL* url = [NSURL URLWithString:@"http://maps.raleighnc.gov/arcgis/rest/services/Parcels/MapServer/exts/PropertySOE/RealEstateSearch"];
    self.jsonOp = [[AGSJSONRequestOperation alloc]initWithURL:url queryParameters:params];
    self.jsonOp.target = self;
    self.jsonOp.action = @selector(operation:didSucceedWithAccounts:);
    self.jsonOp.errorAction = @selector(operation:didFailWithError:);
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    [self.queue cancelAllOperations];
    [self.queue addOperation:self.jsonOp];
    self.searchBar.text = @"";
    _suggestionArray = nil;
    [tableView reloadData];

}


#pragma mark - UISearchBarDelegate Methods
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length > 3) {
        NSMutableDictionary* params = [NSMutableDictionary dictionary];
        [params setObject:searchText forKey:@"input"];
        [params setObject:self.type forKey:@"type"];
        [params setObject:@"jsonp" forKey:@"f"];
        NSURL* url = [NSURL URLWithString:@"http://maps.raleighnc.gov/arcgis/rest/services/Parcels/MapServer/exts/PropertySOE/AutoComplete"];
        self.jsonOp = [[AGSJSONRequestOperation alloc]initWithURL:url queryParameters:params];
        self.jsonOp.target = self;
        self.jsonOp.action = @selector(operation:didSucceedWithResponse:);
        self.jsonOp.errorAction = @selector(operation:didFailWithError:);
        
        [self.queue addOperation:self.jsonOp];
    } else {
        _suggestionArray = nil;
        [self.tableView reloadData];
    }
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [[self view] endEditing:YES];
}


- (void)operation:(NSOperation*)op didSucceedWithResponse:(NSDictionary *)results {
    if ([results objectForKey:@"Results"] != nil) {
        _suggestionArray = [results objectForKey:@"Results"];
        [self.tableView reloadData];
    }
}

- (void)operation:(NSOperation*)op didSucceedWithAccounts:(NSDictionary *)results {
    [SVProgressHUD dismiss];
    if ([results objectForKey:@"Accounts"] != nil) {
        self.accounts = [results objectForKey:@"Accounts"];
        self.fields = [results objectForKey:@"Fields"];
        self.account = [self.accounts objectAtIndex:0];
        
        [self.activity stopAnimating];
        
        if (self.accounts.count > 1) {
            [self performSegueWithIdentifier:@"searchToResults" sender:self];
        } else {
            [self performSegueWithIdentifier:@"searchToInfo" sender:self];
        }
        
    }
}

- (void)operation:(NSOperation*)op didFailWithError:(NSError *)error {
    [SVProgressHUD dismiss];
}

#pragma mark - AGSFindTaskDelegate
-(void)findTask:(AGSFindTask *)findTask operation:(NSOperation *)op didExecuteWithFindResults:(NSArray *)results {
    self.results = results;
    AGSFindResult *result = [results objectAtIndex:0];
    self.graphic = result.feature;
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setObject:self.graphic forKey:@"graphic"];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [[NSNotificationCenter defaultCenter] postNotificationName: @"addGraphicNotification" object: self userInfo: dict];
    } else
    {
        if (results.count > 1) {
            [self performSegueWithIdentifier:@"searchToResults" sender:self];
        } else {
            [self performSegueWithIdentifier:@"searchToInfo" sender:self];
        }

    }

    
}

-(void)findTask:(AGSFindTask *)findTask operation:(NSOperation *)op didFailWithError:(NSError *)error{
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [[self view] endEditing:YES];
    
    NSMutableDictionary* info = [NSMutableDictionary dictionary];

    
    if ([[segue identifier] isEqualToString:@"searchToResults"]){
        if ([segue.destinationViewController respondsToSelector:@selector(setInfo:)]) {
            [info setObject:self.fields forKey:@"fields"];
            [info setObject:self.accounts forKey:@"accounts"];
            [segue.destinationViewController performSelector:@selector(setInfo:)
                                                  withObject:info];
        }
    } else if ([[segue identifier] isEqualToString:@"searchToInfo"]){
        if ([segue.destinationViewController respondsToSelector:@selector(setInfo:)]) {
            [info setObject:self.fields forKey:@"fields"];
            [info setObject:self.account forKey:@"account"];
            [segue.destinationViewController performSelector:@selector(setInfo:)
                                                  withObject:info];
        }
    } else if ([[segue identifier] isEqualToString:@"searchToMap"]) {
        if ([segue.destinationViewController respondsToSelector:@selector(setIsGpsOn:)]) {

            [segue.destinationViewController performSelector:@selector(setIsGpsOn:) withObject:@"YES"];
        }
    }

}
@end
