//
//  StreetViewController.m
//  iMAPSmobile
//
//  Created by Justin Greco on 12/17/13.
//  Copyright (c) 2013 City of Raleigh. All rights reserved.
//

#import "StreetViewController.h"

@interface StreetViewController ()

@end

@implementation StreetViewController
@synthesize webView = _webView;
@synthesize streetViewUrl = _streetViewUrl;
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
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:self.streetViewUrl];
    [self.webView setScalesPageToFit:YES];
    [self.webView setBackgroundColor:[UIColor blackColor]];
    
    [self.webView loadRequest:request];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
