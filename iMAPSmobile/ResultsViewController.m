//
//  ResultsViewController.m
//  iMAPSmobile
//
//  Created by Justin Greco on 10/7/13.
//  Copyright (c) 2013 City of Raleigh. All rights reserved.
//

#import "ResultsViewController.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

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
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.toolbarHidden = YES;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.toolbar.userInteractionEnabled = YES;
    self.navigationController.navigationBar.userInteractionEnabled = YES;
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Results Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)showResults:(NSNotification*)notification {
    self.info = notification.userInfo;
    [self.tableView reloadData];
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

    UILabel *addressLabel = (UILabel *)[cell viewWithTag:100];
    addressLabel.text = [account objectForKey:@"siteAddress"];
    UILabel *ownerLabel = (UILabel *)[cell viewWithTag:101];
    ownerLabel.text = [account objectForKey:@"owner"];
    UILabel *pinLabel = (UILabel *)[cell viewWithTag:102];
    pinLabel.text = [account objectForKey:@"pin"];
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
