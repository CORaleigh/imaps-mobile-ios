//
//  AddressesViewController.m
//  iMAPSmobile
//
//  Created by Justin Greco on 11/8/13.
//  Copyright (c) 2013 City of Raleigh. All rights reserved.
//

#import "AddressesViewController.h"
#import "SVProgressHUD.h"

#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

@interface AddressesViewController ()

@end

@implementation AddressesViewController
@synthesize params = _params, jsonOp = _jsonOp, queue = _queue, addresses = _addresses, pin = _pin, customRowHeight = _customRowHeight;
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
    
    self.navigationController.toolbarHidden = YES;
    self.navigationController.navigationBarHidden = NO;
    self.queue = [[NSOperationQueue alloc] init];
    NSURL *url = [NSURL URLWithString:@"http://maps.raleighnc.gov/arcgis/rest/services/Parcels/MapServer/exts/PropertySOE/AddressSearch"];
    
    [_params setObject:@"jsonp" forKey:@"f"];
    self.jsonOp = [[AGSJSONRequestOperation alloc] initWithURL:url queryParameters:_params];
    self.jsonOp.target = self;
    self.jsonOp.action = @selector(operation:didSucceedWithAddresses:);
    self.jsonOp.errorAction = @selector(operation:didFailWithError:);
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    [self.queue addOperation:self.jsonOp];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Address Screen"];
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
    return [_addresses count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"addressCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    NSDictionary *address = [_addresses objectAtIndex:indexPath.row];
    if ([address objectForKey:@"rpidMap"]) {
        //raleigh
        cell.textLabel.numberOfLines = 4;
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        NSString *suite = [address objectForKey:@"suite"];
        suite = [suite stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *addr = [[address objectForKey:@"address"] capitalizedString];
        NSString *status = [[address objectForKey:@"status"] capitalizedString];
        NSString *type = [[address objectForKey:@"type"] capitalizedString];
        if ([suite length] > 0) {
            cell.textLabel.text = [NSString stringWithFormat:@"%@ Suite %@\n", addr, suite];
        } else {
            cell.textLabel.text = [NSString stringWithFormat:@"%@\n", addr];
        }
        
    
        
        cell.textLabel.text = [cell.textLabel.text stringByAppendingFormat:@"%@\nStatus: ", status];
        cell.textLabel.text = [cell.textLabel.text stringByAppendingFormat:@"%@\nType: ", type];
        
    } else {
        //wake
        cell.textLabel.text = [NSString stringWithFormat:@"%@", [[address objectForKey:@"address"] capitalizedString]];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *address = [_addresses objectAtIndex:indexPath.row];
    if ([address objectForKey:@"rpidMap"]) {
        return 80;
    } else {
        return 40;
    }
}



- (void)operation:(NSOperation*)op didSucceedWithAddresses:(NSDictionary *)results {
    [SVProgressHUD dismiss];
    _addresses = [results objectForKey:@"Addresses"];
    NSDictionary *address1 = [_addresses objectAtIndex:0];
    if ([address1 objectForKey:@"rpidMap"]) {
        [self.navigationItem setTitle:[NSString stringWithFormat:@"%@, %@", [address1 objectForKey:@"rpidMap"], [address1 objectForKey:@"rpidLot"]]];
    }
    [self.tableView reloadData];
}


- (void)operation:(NSOperation*)op didFailWithError:(NSError *)error {
    [SVProgressHUD dismiss];
	//Error encountered while invoking webservice. Alert user
	UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"Sorry"
												 message:[error localizedDescription]
												delegate:nil cancelButtonTitle:@"OK"
									   otherButtonTitles:nil];
	[av show];
}


@end
