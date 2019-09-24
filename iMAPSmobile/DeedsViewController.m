//
//  DeedsViewController.m
//  iMAPSmobile
//
//  Created by Justin Greco on 10/11/13.
//  Copyright (c) 2013 City of Raleigh. All rights reserved.
//

#import "DeedsViewController.h"
#import "PDFCustomViewController.h"
#import "SVProgressHUD.h"


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
    NSURL *url = [NSURL URLWithString:@"https://maps.raleighnc.gov/arcgis/rest/services/Property/Property/MapServer/3/query"];

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params setObject:@"json" forKey:@"f"];
    [params setObject:[[@"REID = '" stringByAppendingString:self.reid] stringByAppendingString:@"'"] forKey:@"where"];
    [params setObject:@"*" forKey:@"outFields"];

    //[params setObject:self.reid forKey:@"reid"];
    self.jsonOp = [[AGSJSONRequestOperation alloc] initWithURL:url queryParameters:params];
    self.jsonOp.target = self;
    self.jsonOp.action = @selector(operation:didSucceedWithDeeds:);
    self.jsonOp.errorAction = @selector(operation:didFailWithError:);
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD show];
    [self.queue addOperation:self.jsonOp];

}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.toolbar.userInteractionEnabled = YES;
    self.navigationController.navigationBar.userInteractionEnabled = YES;
    
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
    NSMutableArray *deeds = [_deeds objectForKey:@"deeds"];
    NSMutableArray *plats = [_deeds objectForKey:@"plats"];
    
    for (int i = 0;i < [plats count];i++) {
        NSDictionary *plat = [plats objectAtIndex:i];
        if ([[plat objectForKey:@"attributes"] objectForKey:@"BOM_DOC_NUM"] == 0 || [[plat objectForKey:@"attributes"] objectForKey:@"BOM_DOC_NUM"] == [NSNull null]) {
            [plats removeObjectAtIndex:i];
        }
    }
    
    for (int i = 0;i < [deeds count];i++) {
        NSDictionary *deed = [deeds objectAtIndex:i];
        if ([[deed objectForKey:@"attributes"] objectForKey:@"DEED_DOC_NUM"] == 0  || [[deed objectForKey:@"attributes"] objectForKey:@"DEED_DOC_NUM"] == [NSNull null] ) {
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
    NSString *title = [NSString new];
    NSArray *deeds = [_deeds objectForKey:@"deeds"];
    NSArray *plats = [_deeds objectForKey:@"plats"];
    if (section == 0 && [deeds count] > 0) {
        title =  @"Deeds";
    }
    else if (section == 0 && [plats count] > 0) {
        title =  @"Plats";
    }
    if (section == 1) {
        title = @"Plats";
    }
    return title;
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
            label = [[[[deeds objectAtIndex:indexPath.row] objectForKey:@"attributes"] objectForKey:@"DEED_DOC_NUM"] stringValue];
            break;
        case 1:
            label = [[[[plats objectAtIndex:indexPath.row] objectForKey:@"attributes"] objectForKey:@"BOM_DOC_NUM"] stringValue];
            break;
        default:
            break;
    }
    // Configure the cell...
    cell.textLabel.text = label;
    return cell;
}
#pragma mark - Navigation
// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"deedsToPdf"]){
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            UINavigationController *nav = (UINavigationController*)segue.destinationViewController;
            PDFCustomViewController *vc = [nav.childViewControllers objectAtIndex:0];
            [vc performSelector:@selector(setUrl:) withObject:_deedUrl];
        } else {
            [segue.destinationViewController performSelector:@selector(setUrl:) withObject:_deedUrl];
        }
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *deeds = [_deeds objectForKey:@"deeds"];
    NSArray *plats = [_deeds objectForKey:@"plats"];
    NSMutableString *baseUrl = [NSMutableString stringWithString:@"http://services.wakegov.com/booksweb/pdfview.aspx?docid="];
    NSString *docNum = @"";
    switch (indexPath.section) {
        case 0:
            docNum = [[[[deeds objectAtIndex:indexPath.row] objectForKey:@"attributes"] objectForKey:@"DEED_DOC_NUM"] stringValue];

            break;
        case 1:
            docNum = [[[[plats objectAtIndex:indexPath.row] objectForKey:@"attributes"] objectForKey:@"BOM_DOC_NUM"] stringValue];


        default:
            break;
    }
    
    [baseUrl appendString:docNum];
    [baseUrl appendString:@"&RecordDate="];
    _deedUrl = [NSURL URLWithString:baseUrl];
    [self performSegueWithIdentifier:@"deedsToPdf" sender:self];
}

- (void)operation:(NSOperation*)op didSucceedWithDeeds:(NSDictionary *)results {
    _deeds = [NSMutableDictionary dictionary];
    [SVProgressHUD dismiss];
    NSArray *deedResults = [results objectForKey:@"features"];
        NSMutableArray *deeds = [NSMutableArray array];
        NSMutableArray *plats = [NSMutableArray array];
        for (int i=0; i < [deedResults count];i++) {
            NSDictionary *deed = [deedResults objectAtIndex:i];
            if ([[deed objectForKey:@"attributes"] objectForKey:@"DEED_DOC_NUM"]) {
                if ([[deed objectForKey:@"attributes"] objectForKey:@"DEED_DOC_NUM"] != 0 && [[deed objectForKey:@"attributes"] objectForKey:@"DEED_DOC_NUM"] != [NSNull null]) {
                    [deeds addObject:deed];
                }
            }
            if ([[deed objectForKey:@"attributes"] objectForKey:@"BOM_DOC_NUM"] != 0 && [[deed objectForKey:@"attributes"] objectForKey:@"BOM_DOC_NUM"] != [NSNull null]) {
                    [plats addObject:deed];
                
            }
        }
        [_deeds setObject:deeds forKey:@"deeds"];
        [_deeds setObject:plats forKey:@"plats"];
        
        if ([deeds count] > 0 || [plats count] > 0) {
            [self.tableView reloadData];
        } else {

            UIAlertController * alert = [UIAlertController
                                         alertControllerWithTitle:NSLocalizedString(@"No Deeds", nil)
                                         message:NSLocalizedString(@"No deeds are available for this property", nil)
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
    
}

- (void)operation:(NSOperation*)op didFailWithError:(NSError *)error {
    [SVProgressHUD dismiss];

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
-(void)setReid:(NSString *)reid {
    _reid = reid;
}

@end
