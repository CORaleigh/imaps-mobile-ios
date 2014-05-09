//
//  ServicesWebViewController.h
//  iMAPSmobile
//
//  Created by Justin Greco on 11/21/13.
//  Copyright (c) 2013 City of Raleigh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>

#define kGeometryBufferService @"http://maps.raleighnc.gov/ArcGIS/rest/services/Utilities/Geometry/GeometryServer"
#define kesriSRUnit_SurveyFoot 9003
#define kNCStatePlane 102719

@interface ServicesWebViewController : UIViewController<AGSFindTaskDelegate, AGSIdentifyTaskDelegate, UIWebViewDelegate, AGSGeometryServiceTaskDelegate>
@property (strong, nonatomic) NSString *pin;
@property (strong, nonatomic) AGSFindTask *findTask;
@property (strong, nonatomic) AGSFindParameters *findParams;
@property (strong, nonatomic) AGSGeometryServiceTask *gst;
@property (strong, nonatomic) AGSIdentifyTask *idTask;
@property (strong, nonatomic) AGSIdentifyParameters *idParams;
@property (strong, nonatomic) NSArray *results;

@property (strong, nonatomic) AGSJSONRequestOperation *jsonOp;
@property (strong, nonatomic) NSOperationQueue *queue;

@property (strong, nonatomic) NSDictionary *config;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end
