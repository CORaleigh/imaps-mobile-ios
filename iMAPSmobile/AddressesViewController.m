//
//  AddressesViewController.m
//  iMAPSmobile
//
//  Created by Justin Greco on 11/8/13.
//  Copyright (c) 2013 City of Raleigh. All rights reserved.
//

#import "AddressesViewController.h"
#import "SVProgressHUD.h"


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
    NSURL *url = [NSURL URLWithString:@"https://maps.raleighnc.gov/arcgis/rest/services/Property/Property/MapServer/4/query"];
    [_params setObject:@"json" forKey:@"f"];
    [_params setObject:[[@"PIN_NUM = '" stringByAppendingString:[self.params objectForKey:@"pin"]] stringByAppendingString:@"' AND ADDR_LIST = 'Yes'"] forKey:@"where"];
    [_params setObject:@"*" forKey:@"outFields"];
    [_params setObject:@"ADDRESS" forKey:@"orderByFields"];
    self.jsonOp = [[AGSJSONRequestOperation alloc] initWithURL:url queryParameters:_params];
    self.jsonOp.target = self;
    self.jsonOp.action = @selector(operation:didSucceedWithAddresses:);
    self.jsonOp.errorAction = @selector(operation:didFailWithError:);
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD show];
    [self.queue addOperation:self.jsonOp];
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
        NSDictionary *address = [_addresses objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [[[address objectForKey:@"attributes"] objectForKey:@"ADDRESS"] capitalizedString]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}



- (void)operation:(NSOperation*)op didSucceedWithAddresses:(NSDictionary *)results {
    [SVProgressHUD dismiss];
    _addresses = [results objectForKey:@"features"];
    [self.tableView reloadData];
}


- (void)operation:(NSOperation*)op didFailWithError:(NSError *)error {
    [SVProgressHUD dismiss];
	//Error encountered while invoking webservice. Alert user
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:NSLocalizedString(@"Sorry", nil)
                                 message:[error localizedDescription]
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* okButton = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"OK", nil)
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   [self.navigationController popViewControllerAnimated:YES];
                               }];
    [alert addAction:okButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}


@end
