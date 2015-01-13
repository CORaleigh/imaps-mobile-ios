//
//  SepticPermitViewController.m
//  iMapsMobile
//
//  Created by Justin Greco on 10/16/14.
//  Copyright (c) 2014 City of Raleigh. All rights reserved.
//

#import "SepticPermitViewController.h"
#import "PDFViewController.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"
@interface SepticPermitViewController ()

@end

@implementation SepticPermitViewController
@synthesize permits = _permits, septicUrl = _septicUrl;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Septic Permits";
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.toolbarHidden = YES;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.permits.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"SepticCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSString *label = @"";


    label = [[self.permits objectAtIndex:indexPath.row] objectForKey:@"permitNumber"];


    
    // Configure the cell...
    cell.textLabel.text = label;
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *permit = [self.permits objectAtIndex:indexPath.row];
    NSString *permitNum = [permit objectForKey:@"permitNumber"];
    id tracker = [[GAI sharedInstance] defaultTracker];
    NSMutableString *baseUrl = [NSMutableString stringWithString:@"http://gisasp2.wakegov.com/imaps/RequestedPermit.aspx?permit="];
    
    [baseUrl appendString:permitNum];
    _septicUrl = [NSURL URLWithString:baseUrl];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Info Events" action:@"Viewed Document" label:@"Septic Permit" value:nil] build]];
    [self performSegueWithIdentifier:@"septicToPdf" sender:self];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UINavigationController *nav = (UINavigationController*)segue.destinationViewController;
        PDFViewController *vc = [nav.childViewControllers objectAtIndex:0];
        [vc performSelector:@selector(setUrl:) withObject:_septicUrl];
    } else {
        [segue.destinationViewController performSelector:@selector(setUrl:) withObject:_septicUrl];
    }
}


@end
