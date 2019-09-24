//
//  PDFViewController.m
//  iMAPSmobile
//
//  Created by Justin Greco on 10/11/13.
//  Copyright (c) 2013 City of Raleigh. All rights reserved.
//

#import "PDFCustomViewController.h"
#import "SingletonData.h"
#import "SVProgressHUD.h"

@interface PDFCustomViewController ()

@end

@implementation PDFCustomViewController
@synthesize webView = _webView;
@synthesize url = _url;

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
    [SVProgressHUD dismiss];

    PDFView *View = [[PDFView alloc] initWithFrame: self.view.bounds];
    View.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    View.autoScales = NO ;
    View.displayDirection = kPDFDisplayDirectionVertical;
    View.displayMode = kPDFDisplaySinglePageContinuous;
    View.displaysRTL = YES ;
    [View setDisplaysPageBreaks:YES];
    [View setDisplayBox:kPDFDisplayBoxTrimBox];
    [View zoomIn:self];
    [self.view addSubview:View];
    
    PDFDocument * document = [[PDFDocument alloc] initWithURL: _url];
    
    View.document = document;
   // NSURLRequest *request = [[NSURLRequest alloc] initWithURL:_url];
    //[self.webView setScalesPageToFit:YES];
//    [self.webView setOpaque:NO];
//    [self.webView setBackgroundColor:[UIColor clearColor]];
//
//    [self.webView loadRequest:request];
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



- (IBAction)doneButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
