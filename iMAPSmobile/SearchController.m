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
    self.searchBar.placeholder = NSLocalizedString(@"Enter an address", nil);
    self.type = @"Address";
    NSURL* url = [NSURL URLWithString:@"https://maps.raleighnc.gov/arcgis/rest/services/Property/Property/MapServer"];
    self.findTask = [[AGSFindTask alloc] initWithURL:url];
    self.findTask.delegate = self;
    self.findParams = [[AGSFindParameters alloc] init];
    
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

-(void)viewWillAppear:(BOOL)animated{

    self.navigationController.navigationBarHidden = NO;
    self.navigationController.toolbarHidden = NO;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.toolbar.translucent = NO;
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

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.toolbar.translucent = NO;
    self.navigationItem.title = NSLocalizedString(@"Search", nil);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)showActionSheet:(UIBarButtonItem *)sender {
//    if ([UIAlertController class]) {
//        UIAlertControllerStyle style = UIAlertControllerStyleActionSheet;
//        UIDeviceOrientation orient = [UIDevice currentDevice].orientation;
//        if (UIDeviceOrientationIsLandscape(orient)) {
//            style = UIAlertControllerStyleAlert;
//        }
//        self.alertController = [UIAlertController alertControllerWithTitle:@"Search By" message:nil preferredStyle: style];
//        UIAlertAction* address = [UIAlertAction actionWithTitle:@"Address" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//            self.type = action.title;
//            self.searchBar.placeholder = @"Enter an address";
//            self.searchBar.keyboardType = UIKeyboardTypeDefault;
//        }];
//        UIAlertAction* owner = [UIAlertAction actionWithTitle:@"Owner" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//            self.type = action.title;
//            self.searchBar.placeholder = @"Enter an owner name";
//            self.searchBar.keyboardType = UIKeyboardTypeDefault;
//        }];
//        UIAlertAction* pin = [UIAlertAction actionWithTitle:@"PIN" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//            self.type = action.title;
//            self.searchBar.placeholder = @"Enter a PIN number";
//            self.searchBar.keyboardType = UIKeyboardTypeNumberPad;
//        }];
//        UIAlertAction* reid = [UIAlertAction actionWithTitle:@"REID" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//            self.type = action.title;
//            self.searchBar.placeholder = @"Enter a real estate ID";
//            self.searchBar.keyboardType = UIKeyboardTypeNumberPad;
//        }];
//        UIAlertAction* street = [UIAlertAction actionWithTitle:@"Street Name" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//            self.type = action.title;
//            self.searchBar.placeholder = @"Enter a street name";
//            self.searchBar.keyboardType = UIKeyboardTypeDefault;
//        }];
//        UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
//            [self.alertController dismissViewControllerAnimated:YES completion:nil];
//        }];
//        [self.alertController addAction:address];
//        [self.alertController addAction:owner];
//        [self.alertController addAction:pin];
//        [self.alertController addAction:reid];
//        [self.alertController addAction:street];
//        [self.alertController addAction:cancel];
//        [self presentViewController:self.alertController animated:YES completion:nil];
//
//    } else {
//            self.actionSheet = [[UIActionSheet alloc] initWithTitle:@"Search By" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Address",@"Owner",@"PIN", @"REID", @"Street Name", nil];
//            self.actionSheet.cancelButtonIndex = self.actionSheet.numberOfButtons - 1;
//
//            [self.actionSheet showInView:self.view];

        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Search By" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
    [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
            // Cancel button tappped.
            [self dismissViewControllerAnimated:YES completion:^{
            }];
        }]];
        
    [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Address", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            self.type = action.title;
            self.searchBar.placeholder =NSLocalizedString(@"Enter an address", nil);
            self.searchBar.keyboardType = UIKeyboardTypeDefault;
            [self dismissViewControllerAnimated:YES completion:^{
            }];
        }]];
        
    [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Owner", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            self.type = action.title;
            self.searchBar.placeholder = NSLocalizedString(@"Enter an owner name", nil);
            self.searchBar.keyboardType = UIKeyboardTypeDefault;
            [self dismissViewControllerAnimated:YES completion:^{
            }];
        }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"PIN", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            self.type = action.title;
            self.searchBar.placeholder = NSLocalizedString(@"Enter a PIN number", nil);
            self.searchBar.keyboardType = UIKeyboardTypeNumberPad;
            [self dismissViewControllerAnimated:YES completion:^{
            }];
        }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"REID", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            self.type = action.title;
            self.searchBar.placeholder = NSLocalizedString(@"Enter a real estate ID", nil);
            self.searchBar.keyboardType = UIKeyboardTypeNumberPad;
            [self dismissViewControllerAnimated:YES completion:^{
            }];
        }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Street Name", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            self.type = action.title;
            self.searchBar.placeholder = NSLocalizedString(@"Enter a street name", nil);
            self.searchBar.keyboardType = UIKeyboardTypeDefault;
            [self dismissViewControllerAnimated:YES completion:^{
            }];
        }]];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [actionSheet.popoverPresentationController setBarButtonItem:sender];
    }
        // Present action sheet.
        [self presentViewController:actionSheet animated:YES completion:nil];

   // }

    
}
- (IBAction)showMap:(id)sender {
    [self performSegueWithIdentifier:@"searchToMap" sender:self];}

//-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
//    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
//    self.type = title;
//    switch (buttonIndex) {
//        case 0:
//            self.searchBar.placeholder = @"Enter an address";
//            self.searchBar.keyboardType = UIKeyboardTypeDefault;
//            break;
//        case 1:
//            self.searchBar.placeholder = @"Enter an owner name";
//            self.searchBar.keyboardType = UIKeyboardTypeDefault;
//            break;
//        case 2:
//            self.searchBar.placeholder = @"Enter a PIN number";
//            self.searchBar.keyboardType = UIKeyboardTypeNumberPad;
//            break;
//        case 3:
//            self.searchBar.placeholder = @"Enter a real estate ID";
//            self.searchBar.keyboardType = UIKeyboardTypeNumberPad;
//            break;
//        case 4:
//            self.searchBar.placeholder = @"Enter a street name";
//            self.searchBar.keyboardType = UIKeyboardTypeDefault;
//            break;
//        default:
//            break;
//    }
//}

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
    if ([self.type isEqualToString:@"Address"] ) {
        cell.textLabel.text=[[[_suggestionArray objectAtIndex:indexPath.row] objectForKey:@"attributes"] objectForKey:@"ADDRESS"];

        
    }
    if ([self.type isEqualToString:@"Owner"] ) {
        cell.textLabel.text=[[[_suggestionArray objectAtIndex:indexPath.row] objectForKey:@"attributes"] objectForKey:@"OWNER"];

        
    }
    if ([self.type isEqualToString:@"PIN"] ) {
        cell.textLabel.text=[[[_suggestionArray objectAtIndex:indexPath.row] objectForKey:@"attributes"] objectForKey:@"PIN_NUM"];

        
    }
    if ([self.type isEqualToString:@"REID"] ) {
        cell.textLabel.text=[[[_suggestionArray objectAtIndex:indexPath.row] objectForKey:@"attributes"] objectForKey:@"REID"];

        
    }
    if ([self.type isEqualToString:@"Street Name"] ) {
        cell.textLabel.text=[[[_suggestionArray objectAtIndex:indexPath.row] objectForKey:@"attributes"] objectForKey:@"STREET"];

        
    }
    return cell;
}

#pragma mark - UITableViewDeletegate Methods


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *selection = [_suggestionArray objectAtIndex:indexPath.row];
   // NSMutableArray *values = [NSMutableArray array];
   // [values addObject:selection];
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    //[params setObject:@"jsonp" forKey:@"f"];
    //[params setObject:self.type forKey:@"type"];
    //[params setObject:values forKey:@"values"];
    [params setObject:@"json" forKey:@"f"];
    [params setObject:@"*" forKey:@"outFields"];
    [params setObject:@"false" forKey:@"returnGeometry"];

    NSURL* url = [NSURL URLWithString:@"https://maps.raleighnc.gov/arcgis/rest/services/Property/Property/MapServer/1/query"];

    if ([self.type isEqualToString:@"Address"] ) {
        NSString *address = [[selection objectForKey:@"attributes"] objectForKey:@"ADDRESS"];
        NSMutableString *where = [NSMutableString new];
        [where setString: @"(PARCEL_STATUS in ('ACT', 'ASSB') or PARCEL_STATUS IS NULL) AND SITE_ADDRESS = '"];
        [where appendString:address];
        [where appendString: @"'"];
        
        if (![address containsString:@" E "] && ![address containsString:@" W "]  && ![address containsString:@" N "] && ![address containsString:@" S "]  ) {
            NSMutableString *addressNodir = [address mutableCopy];
            NSRange firstSpace = [address rangeOfString:@" "];
            [where appendString:@" OR SITE_ADDRESS = '"];
            [where appendString:[addressNodir stringByReplacingCharactersInRange:firstSpace withString:@" N "]];
            [where appendString:@"' OR SITE_ADDRESS = '"];
            addressNodir = [address mutableCopy];
            [where appendString:[addressNodir stringByReplacingCharactersInRange:firstSpace withString:@" S "]];
            [where appendString:@"' OR SITE_ADDRESS = '"];
            addressNodir = [address mutableCopy];
            [where appendString:[addressNodir stringByReplacingCharactersInRange:firstSpace withString:@" E "]];
            [where appendString:@"' OR SITE_ADDRESS = '"];
            addressNodir = [address mutableCopy];
            [where appendString:[addressNodir stringByReplacingCharactersInRange:firstSpace withString:@" W "]];
            [where appendString:@"'"];
        }
        
        [params setObject:where forKey:@"where"];
        [params setObject:@"SITE_ADDRESS" forKey:@"orderByFields"];
    }
    if ([self.type isEqualToString:@"Owner"] ) {
        [params setObject:[[@"(PARCEL_STATUS in ('ACT', 'ASSB') or PARCEL_STATUS IS NULL) AND OWNER = '" stringByAppendingString: [[selection objectForKey:@"attributes"] objectForKey:@"OWNER"]] stringByAppendingString:@"'"] forKey:@"where"];
        [params setObject:@"OWNER" forKey:@"orderByFields"];
    }
    if ([self.type isEqualToString:@"PIN"] ) {
        [params setObject:[[@"(PARCEL_STATUS in ('ACT', 'ASSB') or PARCEL_STATUS IS NULL) AND PIN_NUM = '" stringByAppendingString: [[selection objectForKey:@"attributes"] objectForKey:@"PIN_NUM"]] stringByAppendingString:@"'"] forKey:@"where"];
        [params setObject:@"PIN_NUM" forKey:@"orderByFields"];
    }
    if ([self.type isEqualToString:@"REID"] ) {
        [params setObject:[[@"(PARCEL_STATUS in ('ACT', 'ASSB') or PARCEL_STATUS IS NULL) AND REID = '" stringByAppendingString: [[selection objectForKey:@"attributes"] objectForKey:@"REID"]] stringByAppendingString:@"'"] forKey:@"where"];
        [params setObject:@"REID" forKey:@"orderByFields"];
    }
    if ([self.type isEqualToString:@"Street Name"] ) {
        NSString *street = [[selection objectForKey:@"attributes"] objectForKey:@"STREET"];
        NSMutableString *where = [NSMutableString new];
        [where setString: @"(PARCEL_STATUS in ('ACT', 'ASSB') or PARCEL_STATUS IS NULL) AND FULL_STREET_NAME = '"];
        [where appendString:street];
        [where appendString: @"'"];
        
        if (![street containsString:@" E "] && ![street containsString:@" W "]  && ![street containsString:@" N "] && ![street containsString:@" S "]  ) {
            [where appendString:@" OR FULL_STREET_NAME = '"];
            [where appendString:@"N "];
            [where appendString:street];
            [where appendString:@"' OR FULL_STREET_NAME = '"];
            [where appendString:@"S "];
            [where appendString:street];
            [where appendString:@"' OR FULL_STREET_NAME = '"];
            [where appendString:@"E "];
            [where appendString:street];
            [where appendString:@"' OR FULL_STREET_NAME = '"];
            [where appendString:@"W "];
            [where appendString:street];
            [where appendString:@"' OR FULL_STREET_NAME = '"];
            [where appendString:@"'"];
        }
        
        [params setObject:where forKey:@"where"];
        [params setObject:@"SITE_ADDRESS" forKey:@"orderByFields"];
    }

    self.jsonOp = [[AGSJSONRequestOperation alloc]initWithURL:url queryParameters:params];
    self.jsonOp.target = self;
    self.jsonOp.action = @selector(operation:didSucceedWithAccounts:);
    self.jsonOp.errorAction = @selector(operation:didFailWithError:);
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD show];
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
        [params setObject:@"json" forKey:@"f"];
        [params setObject:@"false" forKey:@"returnGeometry"];
        [params setObject:@"true" forKey:@"returnDistinctValues"];

        NSURL* url = [NSURL URLWithString:@"https://maps.raleighnc.gov/arcgis/rest/services/Property/Property/MapServer/1/query"];
        if ([self.type isEqualToString:@"Address"] ) {
            url = [NSURL URLWithString:@"https://maps.raleighnc.gov/arcgis/rest/services/Property/Property/MapServer/4/query"];
            [params setObject:[[@"ADDRESS LIKE '" stringByAppendingString: [searchText uppercaseString]] stringByAppendingString:@"%'"] forKey:@"where"];
            [params setObject:@"ADDRESS" forKey:@"orderByFields"];
            [params setObject:@"ADDRESS" forKey:@"outFields"];

        }
        if ([self.type isEqualToString:@"Owner"] ) {
            [params setObject:[[@"OWNER LIKE '" stringByAppendingString: [searchText uppercaseString]] stringByAppendingString:@"%'"] forKey:@"where"];
            [params setObject:@"OWNER" forKey:@"orderByFields"];
            [params setObject:@"OWNER" forKey:@"outFields"];

        }
        if ([self.type isEqualToString:@"PIN"] ) {
            [params setObject:[[@"PIN_NUM LIKE '" stringByAppendingString: [searchText uppercaseString]] stringByAppendingString:@"%'"] forKey:@"where"];
            [params setObject:@"PIN_NUM" forKey:@"orderByFields"];
            [params setObject:@"PIN_NUM" forKey:@"outFields"];

        }
        if ([self.type isEqualToString:@"REID"] ) {
            [params setObject:[[@"REID LIKE '" stringByAppendingString: [searchText uppercaseString]] stringByAppendingString:@"%'"] forKey:@"where"];
            [params setObject:@"REID" forKey:@"orderByFields"];
            [params setObject:@"REID" forKey:@"outFields"];

        }
        if ([self.type isEqualToString:@"Street Name"] ) {
            url = [NSURL URLWithString:@"https://maps.raleighnc.gov/arcgis/rest/services/Property/Property/MapServer/4/query"];
            [params setObject:[[@"STREET LIKE '" stringByAppendingString: [searchText uppercaseString]] stringByAppendingString:@"%'"] forKey:@"where"];
            [params setObject:@"STREET" forKey:@"orderByFields"];
            [params setObject:@"STREET" forKey:@"outFields"];

        }

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
    if ([results objectForKey:@"features"] != nil) {
        _suggestionArray = [results objectForKey:@"features"];
        [self.tableView reloadData];
    }
}

- (void)operation:(NSOperation*)op didSucceedWithAccounts:(NSDictionary *)results {
    [SVProgressHUD dismiss];
    if ([results objectForKey:@"features"] != nil) {
        self.accounts = [results objectForKey:@"features"];
        self.fields = [results objectForKey:@"fields"];
        [self.activity stopAnimating];
        if (self.accounts.count > 0) {
            self.account = [self.accounts objectAtIndex:0];
            

            
            if (self.accounts.count > 1) {
                [self performSegueWithIdentifier:@"searchToResults" sender:self];
            } else {
                [self performSegueWithIdentifier:@"searchToInfo" sender:self];
            }
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
//        if ([segue.destinationViewController respondsToSelector:@selector(setIsGpsOn:)]) {
//
//            [segue.destinationViewController performSelector:@selector(setIsGpsOn:) withObject:@"YES"];
//        }
    }

}
@end
