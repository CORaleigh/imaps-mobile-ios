//
//  TaxViewController.m
//  iMAPSmobile
//
//  Created by Justin Greco on 10/11/13.
//  Copyright (c) 2013 City of Raleigh. All rights reserved.
//

#import "TaxViewController.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

@interface TaxViewController ()

@end

@implementation TaxViewController
@synthesize webView = _webView;
@synthesize reid = _reid;
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

    
    NSMutableString *baseUrl = [NSMutableString stringWithString:@"http://services.wakegov.com/realestate/Account.asp?id="];
    NSURL* url = [NSURL URLWithString:[baseUrl stringByAppendingString:_reid]];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [self.webView setScalesPageToFit:YES];
    [self.webView loadRequest:request];
    self.webView.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Real Estate Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {

    [self.backButton setEnabled:(self.webView.canGoBack)];
}


- (IBAction)backButtonTap:(id)sender {
    if (self.webView.canGoBack) {
        [self.webView goBack];
    }
}

- (IBAction)doneButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
