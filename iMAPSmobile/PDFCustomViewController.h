//
//  PDFViewController.h
//  iMAPSmobile
//
//  Created by Justin Greco on 10/11/13.
//  Copyright (c) 2013 City of Raleigh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <PDFKit/PDFKit.h>
@interface PDFCustomViewController : UIViewController<UIWebViewDelegate, UIPageViewControllerDelegate, PDFViewDelegate>

//@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet WKWebView *webView;

@property (strong, nonatomic) NSURL *url;
- (IBAction)doneButtonTapped:(id)sender;
@end
