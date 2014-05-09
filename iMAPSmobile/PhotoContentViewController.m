//
//  PhotoContentViewController.m
//  iMAPSmobile
//
//  Created by Justin Greco on 10/11/13.
//  Copyright (c) 2013 City of Raleigh. All rights reserved.
//

#import "PhotoContentViewController.h"

@interface PhotoContentViewController ()

@end

@implementation PhotoContentViewController
@synthesize webView = _webView, request = _request;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

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
        _webView.scalesPageToFit = NO;
    } else {
        _webView.scalesPageToFit = YES;
        
    }
    _webView.scrollView.bounces = NO;
    self.webView.delegate = self;
    [_webView loadRequest: _request];
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    //self.webView.frame = self.view.frame;
    CGRect rect = self.view.frame;
    
    int statusBarHeight = 20;
    
    int navBarHeight = self.navigationController.navigationBar.frame.size.height;
    
    
    
    rect.origin.y = statusBarHeight + navBarHeight;
    rect.size.height -= navBarHeight - statusBarHeight;
    [_webView setFrame:rect];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewDidAppear:(BOOL)animated {
    CGRect rect = self.view.frame;
    
    int statusBarHeight = 20;
    
    int navBarHeight = self.navigationController.navigationBar.frame.size.height;
    
    
    
    rect.origin.y = statusBarHeight + navBarHeight;
    rect.size.height -= navBarHeight - statusBarHeight;
    [_webView setFrame:rect];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


-(void)webViewDidStartLoad:(UIWebView *)webView {
    CGRect rect = self.view.frame;
    
    int statusBarHeight = 20;
    
    int navBarHeight = self.navigationController.navigationBar.frame.size.height;
    
    
    
    rect.origin.y = statusBarHeight + navBarHeight;
    rect.size.height -= navBarHeight - statusBarHeight;
    [_webView setFrame:rect];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    CGRect rect = self.view.frame;
    
    int statusBarHeight = 20;
    
    int navBarHeight = self.navigationController.navigationBar.frame.size.height;
    
    
    
    rect.origin.y = statusBarHeight + navBarHeight;
    rect.size.height -= navBarHeight - statusBarHeight;
    [_webView setFrame:rect];
}


@end
