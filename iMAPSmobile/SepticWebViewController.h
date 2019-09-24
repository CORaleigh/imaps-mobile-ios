//
//  SepticWebViewController.h
//  
//
//  Created by Greco, Justin on 9/19/19.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>


@interface SepticWebViewController : UIViewController
@property (strong, nonatomic) IBOutlet WKWebView *webView;

@property (strong, nonatomic) NSString *reid;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
- (IBAction)backButtonTap:(id)sender;
- (IBAction)doneButtonTapped:(id)sender;
@end

NS_ASSUME_NONNULL_END
