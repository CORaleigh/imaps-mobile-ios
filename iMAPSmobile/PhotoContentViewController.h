//
//  PhotoContentViewController.h
//  iMAPSmobile
//
//  Created by Justin Greco on 10/11/13.
//  Copyright (c) 2013 City of Raleigh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoContentViewController : UIViewController<UIWebViewDelegate, UIPageViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) NSURLRequest *request;

@end
