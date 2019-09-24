//
//  LegendViewController.m
//  iMAPSmobile
//
//  Created by Justin Greco on 10/10/13.
//  Copyright (c) 2013 City of Raleigh. All rights reserved.
//

#import "LegendViewController.h"
#import "LegendCell.h"


@interface LegendViewController ()

@end

@implementation LegendViewController
@synthesize layerInfos = _layerInfos;
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
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    

}

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
    return [_layerInfos count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    AGSMapServiceLayerInfo *layerInfo = [_layerInfos objectAtIndex:section];
    NSArray *legendLabels = layerInfo.legendLabels;
    return [legendLabels count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"LegendCell";
    LegendCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil){
        cell = [[LegendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    // Configure the cell...
    AGSMapServiceLayerInfo *layerInfo = [_layerInfos objectAtIndex:indexPath.section];

    cell.legendLabel.text = [layerInfo.legendLabels objectAtIndex:indexPath.row];
    [cell.legendImage setImage:[layerInfo.legendImages objectAtIndex:indexPath.row]];
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    AGSMapServiceLayerInfo *layerInfo = [_layerInfos objectAtIndex:section];
    return layerInfo.name;
}

@end
