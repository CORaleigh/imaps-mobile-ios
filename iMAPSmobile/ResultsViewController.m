//
//  ResultsViewController.m
//  iMAPSmobile
//
//  Created by Justin Greco on 10/7/13.
//  Copyright (c) 2013 City of Raleigh. All rights reserved.
//

#import "ResultsViewController.h"

@interface ResultsViewController ()

@end

@implementation ResultsViewController
@synthesize info = _info, tableView = _tableView, account = _account;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.toolbarHidden = YES;

    [self.tableView reloadData];
    self.view = self.tableView;
    

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (@available(iOS 13, *)) {
        if(self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
            self.navigationController.navigationBar.barTintColor = [UIColor blackColor];

        } else {
            self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
        }
    }
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.toolbarHidden = YES;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.toolbar.userInteractionEnabled = YES;
    self.navigationController.navigationBar.userInteractionEnabled = YES;
    
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


-(void)showResults:(NSNotification*)notification {
    self.info = notification.userInfo;
    [self.tableView reloadData];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [[UIApplication sharedApplication] sendAction:self.splitViewController.displayModeButtonItem.action to:self.splitViewController.displayModeButtonItem.target from:nil forEvent:nil ];
    }
        
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray *accounts = [_info objectForKey:@"accounts"];
    return [accounts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ResultCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSMutableArray *accounts = [_info objectForKey:@"accounts"];
    NSDictionary *account = [accounts objectAtIndex:indexPath.row];
    NSDictionary *attributes = [account objectForKey:@"attributes"];

    UILabel *addressLabel = (UILabel *)[cell viewWithTag:100];
    addressLabel.text = [attributes objectForKey:@"SITE_ADDRESS"];
    UILabel *ownerLabel = (UILabel *)[cell viewWithTag:101];
    ownerLabel.text = [attributes objectForKey:@"OWNER"];
    UILabel *pinLabel = (UILabel *)[cell viewWithTag:102];
    pinLabel.text = [attributes objectForKey:@"PIN_NUM"];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *accounts = [_info objectForKey:@"accounts"];

    _account = [accounts objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"resultsToInfo" sender:self];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    if ([[segue identifier] isEqualToString:@"resultsToInfo"]){
        if ([segue.destinationViewController respondsToSelector:@selector(setInfo:)]) {
            [dict setObject:[_info objectForKey:@"fields"] forKey:@"fields"];
            [dict setObject:_account forKey:@"account"];
            [segue.destinationViewController performSelector:@selector(setInfo:)
                                                  withObject:dict];
        }
    }
}




- (IBAction)returnToSearch:(id)sender {
    [self performSegueWithIdentifier:@"resultsToSearch" sender:self];
}

@end
