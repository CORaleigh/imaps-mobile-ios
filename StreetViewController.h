//
//  StreetViewController.h
//  iMAPSmobile
//
//  Created by Justin Greco on 12/17/13.
//  Copyright (c) 2013 City of Raleigh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StreetViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) NSURL *streetViewUrl;
- (IBAction)dismissView:(id)sender;
@end
