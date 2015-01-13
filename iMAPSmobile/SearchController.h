//
//  SearchController.h
//  iMAPSmobile
//
//  Created by Justin Greco on 10/3/13.
//  Copyright (c) 2013 City of Raleigh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>
#import "GAITrackedViewController.h"

@class ViewController;

@interface SearchController : GAITrackedViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, AGSFindTaskDelegate, UIActionSheetDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) AGSJSONRequestOperation *jsonOp;
@property (strong, nonatomic) NSOperationQueue *queue;
@property (strong, nonatomic) NSArray *suggestionArray;
@property (strong, nonatomic) AGSFindTask *findTask;
@property (strong, nonatomic) AGSFindParameters *findParams;
@property (strong, nonatomic) AGSGraphic *graphic;
@property (strong, nonatomic) NSArray *results;
@property (strong, nonatomic) AGSFindResult *findResult;
@property (strong, nonatomic) ViewController *detailViewController;
@property (strong, nonatomic) UIActionSheet *actionSheet;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *searchBy;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSMutableArray *accounts;
@property (strong, nonatomic) NSDictionary *account;
@property (strong, nonatomic) NSMutableArray *fields;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (strong, nonatomic) UIView *progressView;
@property (strong, nonatomic) UIAlertController *alertController;

@end
