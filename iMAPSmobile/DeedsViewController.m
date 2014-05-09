//
//  DeedsViewController.m
//  iMAPSmobile
//
//  Created by Justin Greco on 10/11/13.
//  Copyright (c) 2013 City of Raleigh. All rights reserved.
//

#import "DeedsViewController.h"
#import "PDFViewController.h"
#import "SVProgressHUD.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

@interface DeedsViewController ()

@end

@implementation DeedsViewController
@synthesize reid = _reid, jsonOp = _jsonOp, queue = _queue, deeds = _deeds;
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
    self.navigationController.toolbarHidden = YES;
    self.queue = [[NSOperationQueue alloc] init];
    NSURL *url = [NSURL URLWithString:@"http://maps.raleighnc.gov/arcgis/rest/services/Parcels/MapServer/exts/PropertySOE/DeedSearch"];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@"jsonp" forKey:@"f"];
    [params setObject:self.reid forKey:@"reid"];
    self.jsonOp = [[AGSJSONRequestOperation alloc] initWithURL:url queryParameters:params];
    self.jsonOp.target = self;
    self.jsonOp.action = @selector(operation:didSucceedWithDeeds:);
    self.jsonOp.errorAction = @selector(operation:didFailWithError:);
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    [self.queue addOperation:self.jsonOp];

}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.toolbar.userInteractionEnabled = YES;
    self.navigationController.navigationBar.userInteractionEnabled = YES;
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Deed Screen"];
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
    NSMutableArray *deeds = [_deeds objectForKey:@"deeds"];
    NSMutableArray *plats = [_deeds objectForKey:@"plats"];
    
    for (int i = 0;i < [plats count];i++) {
        NSDictionary *plat = [plats objectAtIndex:i];
        if ([[plat objectForKey:@"bomDocNum"] isEqualToString:@"0" ]) {
            [plats removeObjectAtIndex:i];
        }
    }
    
    for (int i = 0;i < [deeds count];i++) {
        NSDictionary *deed = [deeds objectAtIndex:i];
        if ([[deed objectForKey:@"deedDocNum"] isEqualToString:@"0" ]) {
            [deeds removeObjectAtIndex:i];
        }
    }
    
    if ([deeds count] > 0 && [plats count] > 0) {
        return 2;
    } else if ([deeds count] > 0 || [plats count] > 0) {
        return 1;
    } else {
        return 0;
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return (section == 0)?@"Deeds":@"Plats";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSArray *deeds = [_deeds objectForKey:@"deeds"];
    NSArray *plats = [_deeds objectForKey:@"plats"];
    switch (section) {
        case 0:
            return [deeds count];
            break;
        case 1:
            return [plats count];
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DeedCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSString *label = @"";
    NSArray *deeds = [_deeds objectForKey:@"deeds"];
    NSArray *plats = [_deeds objectForKey:@"plats"];
    switch (indexPath.section) {
        case 0:
            label = [[deeds objectAtIndex:indexPath.row] objectForKey:@"deedDocNum"];
            break;
        case 1:
            label = [[plats objectAtIndex:indexPath.row] objectForKey:@"bomDocNum"];
            break;
        default:
            break;
    }
    
    // Configure the cell...
    cell.textLabel.text = label;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *deeds = [_deeds objectForKey:@"deeds"];
    NSArray *plats = [_deeds objectForKey:@"plats"];
    id tracker = [[GAI sharedInstance] defaultTracker];
    NSMutableString *baseUrl = [NSMutableString stringWithString:@"http://services.wakegov.com/booksweb/pdfview.aspx?docid="];
    NSString *docNum = @"";
    switch (indexPath.section) {
        case 0:
            docNum = [[deeds objectAtIndex:indexPath.row] objectForKey:@"deedDocNum"];
            
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Info Events" action:@"Viewed Document" label:@"Deed" value:nil] build]];
            break;
        case 1:
            docNum = [[plats objectAtIndex:indexPath.row] objectForKey:@"bomDocNum"];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Info Events" action:@"Viewed Document" label:@"Plat" value:nil] build]];

        default:
            break;
    }
    
    [baseUrl appendString:docNum];
    [baseUrl appendString:@"&RecordDate="];
    _deedUrl = [NSURL URLWithString:baseUrl];
    [self performSegueWithIdentifier:@"deedsToPdf" sender:self];
}


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"deedsToPdf"]){
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            UINavigationController *nav = (UINavigationController*)segue.destinationViewController;
            PDFViewController *vc = [nav.childViewControllers objectAtIndex:0];
            [vc performSelector:@selector(setUrl:) withObject:_deedUrl];
        } else {
            [segue.destinationViewController performSelector:@selector(setUrl:) withObject:_deedUrl];
        }
    }
}



- (void)operation:(NSOperation*)op didSucceedWithDeeds:(NSDictionary *)results {
    _deeds = [NSMutableDictionary dictionary];
    [SVProgressHUD dismiss];
    NSArray *deedResults = [results objectForKey:@"Deeds"];
        NSMutableArray *deeds = [NSMutableArray array];
        NSMutableArray *plats = [NSMutableArray array];
        for (int i=0; i < [deedResults count];i++) {
            NSDictionary *deed = [deedResults objectAtIndex:i];
            if ([deed objectForKey:@"deedDocNum"]) {
                if (![[deed objectForKey:@"deedDocNum"] isEqualToString:@"0"]) {
                    [deeds addObject:deed];
                }
            }
            if (![[deed objectForKey:@"bomDocNum"] isEqualToString:@"0"]) {
                if ([deed objectForKey:@"bomDocNum"] > 0) {
                    [plats addObject:deed];
                }
            }
        }
        
        [_deeds setObject:deeds forKey:@"deeds"];
        [_deeds setObject:plats forKey:@"plats"];
        
        if ([deeds count] > 0 || [plats count] > 0) {
            [self.tableView reloadData];
        } else {
            UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"No Deeds"
                                                     message:@"No deeds are available for this property"
                                                    delegate:self cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
            [av show];
        }
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)operation:(NSOperation*)op didFailWithError:(NSError *)error {
	//Error encountered while invoking webservice. Alert user
    [SVProgressHUD dismiss];
	UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"Sorry"
												 message:[error localizedDescription]
												delegate:self cancelButtonTitle:@"OK"
									   otherButtonTitles:nil];
	[av show];
}
-(void)setReid:(NSString *)reid {
    _reid = reid;
}

@end
