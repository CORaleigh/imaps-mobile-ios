//
//  ServicesWebViewController.m
//  iMAPSmobile
//
//  Created by Justin Greco on 11/21/13.
//  Copyright (c) 2013 City of Raleigh. All rights reserved.
//

#import "ServicesWebViewController.h"
#import "SVProgressHUD.h"
#import "SingletonData.h"

@interface ServicesWebViewController ()

@end

@implementation ServicesWebViewController
@synthesize pin = _pin, findParams = _findParams, findTask = _findTask, idParams = _idParams, idTask = _idTask, results = _results, queue = _queue, jsonOp = _jsonOp, config = _config, webView = _webView, gst = _gst;

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
    
    self.navigationController.toolbarHidden = YES;
    [self.webView setOpaque:NO];
    [self.webView setBackgroundColor:[UIColor clearColor]];
    
    
    self.queue = [[NSOperationQueue alloc] init];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD show];
    

    NSURL *url = [NSURL URLWithString:@"https://maps.raleighnc.gov/iMAPS_iOS/services.txt"];
    self.jsonOp = [[AGSJSONRequestOperation alloc] initWithURL:url];
    self.jsonOp.requestCachePolicy = NSURLRequestReloadIgnoringCacheData;
    self.jsonOp.target = self;
    self.jsonOp.action = @selector(operation:didSucceedWithResponse:);
    [self.queue addOperation:self.jsonOp];
    //self.webView.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)operation:(NSOperation*)op didSucceedWithResponse:(NSDictionary *) results {
    NSURL *url = [NSURL URLWithString:@"https://maps.raleighnc.gov/arcgis/rest/services/Parcels/MapServer"];
    
    _config = results;
    self.findTask = [[AGSFindTask alloc] initWithURL:url];
    self.findTask.delegate = self;
    self.findParams = [[AGSFindParameters alloc] init];
    
    
    url = [NSURL URLWithString:[[results objectForKey:@"service"] objectForKey:@"url"]];
    self.idTask = [[AGSIdentifyTask alloc] initWithURL:url];
    self.idTask.delegate = self;
    self.idParams = [[AGSIdentifyParameters alloc] init];
    
    
    self.findParams.searchText = self.pin;
    self.findParams.searchFields = [NSArray arrayWithObjects:@"PIN_NUM", nil];
    self.findParams.layerIds = [NSArray arrayWithObjects:@"0",@"1", nil];
    self.findParams.returnGeometry = YES;
    [self.findTask executeWithParameters:self.findParams];
}

- (void) webView:(WKWebView *)webView2 decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if (![navigationAction.request.URL.absoluteString isEqualToString:@"about:blank"]) {
        decisionHandler(WKNavigationActionPolicyCancel);
        UIApplication *application = [UIApplication sharedApplication];
        [application openURL:navigationAction.request.URL options:@{} completionHandler:nil];
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);

    }

    
}

#pragma mark - Find
- (void) findTask:(AGSFindTask *)findTask operation:(NSOperation *)op didExecuteWithFindResults:(NSArray *)results {
    if ([results count] > 0) {
        AGSFindResult *result = [results objectAtIndex:0];
        if (result.feature.geometry) {
            self.gst = [[AGSGeometryServiceTask alloc] initWithURL:[NSURL URLWithString:kGeometryBufferService]];
            AGSSpatialReference *sr = [[AGSSpatialReference alloc] initWithWKID:kNCStatePlane];
            self.gst.delegate = self;
            AGSBufferParameters *bufferParams = [[AGSBufferParameters alloc] init];
            bufferParams.unit = AGSSRUnitFoot;
            bufferParams.bufferSpatialReference = sr;
            bufferParams.distances = [NSArray arrayWithObjects:[NSNumber numberWithInt:-5], nil];
            NSArray *geoms = [NSArray arrayWithObject:result.feature.geometry];
            bufferParams.geometries = geoms;
            bufferParams.outSpatialReference = sr;
            bufferParams.unionResults = FALSE;
            [self.gst bufferWithParameters:bufferParams];
        }
    }
}

- (void) geometryServiceTask:(AGSGeometryServiceTask *)geometryServiceTask operation:(NSOperation *)op didReturnBufferedGeometries:(NSArray *)bufferedGeometries {
    [SVProgressHUD dismiss];
    if (bufferedGeometries.count > 0) {
        self.idParams.geometry = [bufferedGeometries objectAtIndex:0];
        self.idParams.layerOption = AGSIdentifyParametersLayerOptionAll;
        self.idParams.mapEnvelope = self.idParams.geometry.envelope;
        self.idParams.dpi = 96;
        self.idParams.size = self.view.frame.size;
        [self.idTask executeWithParameters:self.idParams];
    }
}

- (void) geometryServiceTask:(AGSGeometryServiceTask *)geometryServiceTask operation:(NSOperation *)op didFailBufferWithError:(NSError *)error {
    [SVProgressHUD dismiss];
}

- (void) findTask:(AGSFindTask *)findTask operation:(NSOperation *)op didFailWithError:(NSError *)error {
    [SVProgressHUD dismiss];
}

#pragma mark - Identify
- (void) identifyTask:(AGSIdentifyTask *)identifyTask operation:(NSOperation *)op didExecuteWithIdentifyResults:(NSArray *)results {
    //self.results = results;
    [SVProgressHUD dismiss];

    [self buildHtml:results];
    
}

- (void) identifyTask:(AGSIdentifyTask *)identifyTask operation:(NSOperation *)op didFailWithError:(NSError *)error {
    
}

- (NSMutableString*) checkCategoryHasValues:(NSMutableString*) html {
    if ([[html substringFromIndex:html.length-5] isEqualToString:@"</h3>"]) {
        NSRange range= [html rangeOfString:@"</p>" options:NSBackwardsSearch];
        NSRange range2 = NSMakeRange(range.location, html.length - range.location);
        [html replaceCharactersInRange:range2 withString:@""];
    }
    return html;
}

- (void) buildHtml:(NSArray *) results {
    
    NSMutableString *html = [NSMutableString stringWithString:(NSString *)@"<html><head><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'></head><body style='font-family:Arial;'>"];
    NSArray *cats = [_config objectForKey:@"categories"];
    NSString *lastLine = @"";
    for (NSDictionary *cat in cats) {
        html = [self checkCategoryHasValues:html];
        [html appendString:[NSString stringWithFormat:@"<h3>%@</h3>", [cat objectForKey:@"title"]]];
        NSArray *srvs = [cat objectForKey:@"services"];
        for (NSDictionary *srv in srvs) {
            NSString *layerId = [srv objectForKey:@"layerId"];
            int lid = [layerId intValue];
            NSArray *filtered = [results filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"layerId == %d", lid]];
            
            if ([filtered count] > 0) {
                for (AGSIdentifyResult *iresult in filtered) {
                    NSString *title = [srv objectForKey:@"title"];
                    title = [self replaceWithFieldValue:title result:iresult];
                    NSMutableString *line = [NSMutableString stringWithString:@""];
                    
                    [line appendString:[NSString stringWithFormat:@"<strong>%@</strong>", title]];
                    NSString *labelStr = [srv objectForKey:@"labels"];
                    NSArray *labels = [labelStr componentsSeparatedByString:@";"];
                    NSString *urlStr = [srv objectForKey:@"urls"];
                    NSArray *urls = [urlStr componentsSeparatedByString:@";"];
                    for (int i = 0;i < [labels count];i++) {
                        NSString *label = [labels objectAtIndex:i];
                        label = [self replaceWithFieldValue:label result:iresult];
                        if ([urls count] > i && ![urls[i] isEqualToString:@""]) {
                            NSString *url = urls[i];
                            url = [self replaceWithFieldValue:url result:iresult];
                            [line appendString:[NSString stringWithFormat:@"<p><a href='%@'>%@</a></p>", url, label]];
                        } else {
                            [line appendString:[NSString stringWithFormat:@"<p>%@</p>", label]];

                        }
                    }
                    if (![lastLine isEqualToString:line]) {
                        [html appendString:line];
                    }
                    lastLine = line;

                }
            }
        }
    }
    



    html = [self checkCategoryHasValues:html];
    [html appendString:@"</body></html>"];
    [self.webView loadHTMLString:html baseURL:nil];

    self.webView.navigationDelegate = self;
    
    
}

- (NSString*) replaceWithFieldValue: (NSString*) value result: (AGSIdentifyResult*) result {
    NSArray *fields = [value componentsSeparatedByString:@"["];
    NSUInteger fieldCnt = [fields count];
    if (fieldCnt > 1) {
        for (int i = 0;i < fieldCnt - 1;i++) {
            NSRange start = [value rangeOfString:@"["];
            NSString *fieldName = [value substringFromIndex:start.location+1];
            NSRange end = [fieldName rangeOfString:@"]"];
            fieldName = [fieldName substringToIndex:end.location];
            if ([result.feature attributeAsStringForKey:fieldName]) {
                value = [value stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"[%@]", fieldName] withString:[result.feature attributeAsStringForKey:fieldName]];
                
            }
        }
    }

    return value;
}

//- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
//    if (![request.URL isEqual:[NSURL URLWithString:@"about:blank"]]) {
//        [[UIApplication sharedApplication] openURL:request.URL];
//        return FALSE;
//    } else {
//        return TRUE;
//    }
//}



@end
