//
//  PhotoContentViewController.h
//  iMAPSmobile
//
//  Created by Justin Greco on 10/11/13.
//  Copyright (c) 2013 City of Raleigh. All rights reserved.
//

#import <WebKit/WebKit.h>
@interface PhotoContentViewController : UIViewController<UIPageViewControllerDelegate>
@property (strong, nonatomic) IBOutlet WKWebView *webView;
@property (strong, nonatomic) NSURLRequest *request;

@end
