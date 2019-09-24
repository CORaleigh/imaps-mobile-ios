//
//  TaxViewController.m
//  iMAPSmobile
//
//  Created by Justin Greco on 10/11/13.
//  Copyright (c) 2013 City of Raleigh. All rights reserved.
//

#import "TaxViewController.h"

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
    // Do any additional setup after loading the view.
    self.navigationController.toolbar.userInteractionEnabled = YES;
    self.navigationController.navigationBar.userInteractionEnabled = YES;
    [_webView setOpaque:NO];
    _webView.scrollView.scrollEnabled = NO;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        //        _webView.scalesPageToFit = NO;
    } else {
        //        _webView.scalesPageToFit = YES;
    }
    _webView.scrollView.bounces = NO;
    //self.webView.delegate = self;
    
    NSMutableString *baseUrl = [NSMutableString stringWithString:@"http://services.wakegov.com/realestate/Account.asp?id="];
    NSURL* url = [NSURL URLWithString:[baseUrl stringByAppendingString:_reid]];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
   // [self.webView setScalesPageToFit:YES];
    [self.webView loadRequest:request];
    //self.webView.delegate = self;
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

//-(void)webViewDidFinishLoad:(UIWebView *)webView {
//
//    [self.backButton setEnabled:(self.webView.canGoBack)];
//}


- (IBAction)backButtonTap:(id)sender {
    if (self.webView.canGoBack) {
        [self.webView goBack];
    }
}

//-(void)viewDidLayoutSubviews {
//    [super viewDidLayoutSubviews];
//    //self.webView.frame = self.view.frame;
//    CGRect rect = self.view.frame;
//
//    int statusBarHeight = 20;
//
//    int navBarHeight = self.navigationController.navigationBar.frame.size.height;
//
//
//
//    rect.origin.y = statusBarHeight + navBarHeight;
//    rect.size.height -= navBarHeight - statusBarHeight;
//    [_webView setFrame:rect];
//}

- (IBAction)doneButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
