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
    return self;
}
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    BOOL portrait = NO;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;

    if(orientation == UIInterfaceOrientationLandscapeLeft) {
        portrait = YES;
    } else if(orientation == UIInterfaceOrientationLandscapeRight) {
        portrait = YES;
    }
    [self loadWebView:(portrait)];
}
- (void)loadWebView:(BOOL)portrait {
    NSString *style = [NSString new];

    NSMutableString *html = [NSMutableString stringWithString:(NSString *)@"<html><head><meta name='viewport' content='width=device-width,initial-scale=1,maximum-scale=1'></head><body style='margin:0'><img style='"];
    if(portrait == YES) { //Default orientation
        style = @"max-width:100%";
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            self.parentViewController.navigationController.toolbarHidden = NO;
        }
    } else {
        style = @"max-height:100%";
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {

    self.parentViewController.navigationController.toolbarHidden = YES;
        }
    }
    
    [NSString stringWithFormat:@"%f", self.webView.frame.size.height];

    [html appendString:style];

    [html appendString:@";' src='"];
    [html appendString:_request.URL.absoluteString];
    [html appendString: @"'></body></html>"];
    [self.webView loadHTMLString:html baseURL:nil];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationController.toolbar.userInteractionEnabled = YES;
    self.navigationController.navigationBar.userInteractionEnabled = YES;
    [_webView setOpaque:NO];
    _webView.scrollView.scrollEnabled = NO;
    _webView.scrollView.bounces = NO;
    
    BOOL portrait = NO;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if(orientation == 0) { //Default orientation
        portrait = YES;
    } else if(orientation == UIInterfaceOrientationPortrait) {
        portrait = YES;

    }
    [self loadWebView:(portrait)];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
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
@end
