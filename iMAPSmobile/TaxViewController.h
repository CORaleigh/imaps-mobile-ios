//
//  TaxViewController.h
//  iMAPSmobile
//
//  Created by Justin Greco on 10/11/13.
//  Copyright (c) 2013 City of Raleigh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TaxViewController : UIViewController <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) NSString *reid;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
- (IBAction)backButtonTap:(id)sender;
- (IBAction)doneButtonTapped:(id)sender;
@end
