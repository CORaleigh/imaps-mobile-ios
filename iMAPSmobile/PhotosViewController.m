//
//  PhotosViewController.m
//  iMAPSmobile
//
//  Created by Justin Greco on 10/11/13.
//  Copyright (c) 2013 City of Raleigh. All rights reserved.
//

#import "PhotosViewController.h"
#import "PhotoContentViewController.h"
#import "SVProgressHUD.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"
@interface PhotosViewController ()

@end

@implementation PhotosViewController
@synthesize reid = _reid, jsonOp = _jsonOp, queue = _queue, photos = _photos, pageContent = _pageContent, currentURL = _currentURL, pageViewController = _pageViewController;
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

    self.navigationController.toolbarHidden = NO;
    self.navigationController.navigationBarHidden = NO;
    self.queue = [[NSOperationQueue alloc] init];
    NSURL *url = [NSURL URLWithString:@"http://maps.raleighnc.gov/arcgis/rest/services/Parcels/MapServer/exts/PropertySOE/PhotoSearch"];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@"jsonp" forKey:@"f"];
    [params setObject:self.reid forKey:@"reid"];
    self.jsonOp = [[AGSJSONRequestOperation alloc] initWithURL:url queryParameters:params];
    self.jsonOp.target = self;
    self.jsonOp.action = @selector(operation:didSucceedWithPhotos:);
    self.jsonOp.errorAction = @selector(operation:didFailWithError:);
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    [self.queue addOperation:self.jsonOp];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Photos Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) createContentPages
{
    NSMutableArray *requests = [[NSMutableArray alloc] init];

    for (int i  = 0; i < [_photos count];i++) {
        NSMutableString *urlString = [NSMutableString stringWithString:@"http://services.wakegov.com/realestate/photos/mvideo/"];
        NSDictionary *photo = [_photos objectAtIndex:i];
        [urlString appendString:[photo objectForKey:@"imageDir"]];
        [urlString appendString:@"/"];
        [urlString appendString:[photo objectForKey:@"imageName"]];
    
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        [requests addObject:request];
        _pageContent = [[NSArray alloc] initWithArray:requests];
    }
}


-(PhotoContentViewController *)viewControllerAtIndex: (NSUInteger) index {
    if([self.pageContent class] == 0 || (index >= [self.pageContent count])) {
        return nil;
    }
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]];
    PhotoContentViewController *dataViewController = [storyboard instantiateViewControllerWithIdentifier:@"photoView"];

    
    
    dataViewController.request = _pageContent[index];
    _currentURL = dataViewController.request.URL;
    return dataViewController;
}

-(NSUInteger)indexOfViewController:(PhotoContentViewController *)viewController
{
    return [_pageContent indexOfObject:viewController.request];
}



-(void)setPageTitle:(NSUInteger) index {
    NSMutableString *title = [NSMutableString stringWithString:@"Photo "];
    [title appendString:[NSString stringWithFormat:@"%lu", (unsigned long) index + 1]];
    [title appendString:@" of "];
    [title appendString:[NSString stringWithFormat:@"%lu", (unsigned long)[_photos count]]];
    self.title = title;
}

-(void)pageViewController:(UIPageViewController *) pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    if (completed) {
        PhotoContentViewController *currentViewController = [self.pageViewController.viewControllers objectAtIndex:0];


        NSUInteger index = [self indexOfViewController:currentViewController];
        [self setPageTitle:index];

    }

}


-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSUInteger index = [self indexOfViewController:(PhotoContentViewController *)viewController];
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    return [self viewControllerAtIndex:index];
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSUInteger index = [self indexOfViewController:(PhotoContentViewController *)viewController];
    if (index == NSNotFound) {
        return nil;
    }
    
    index--;

    return [self viewControllerAtIndex:index];
}

-(NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return [_photos count];
}

-(NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    return 0;
}


- (void)operation:(NSOperation*)op didSucceedWithPhotos:(NSDictionary *)results {
    [SVProgressHUD dismiss];
    _photos = [results objectForKey:@"Photos"];
    if(_photos.count > 0) {
        [self createContentPages];
        NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:UIPageViewControllerSpineLocationMin] forKey:UIPageViewControllerOptionSpineLocationKey];
        _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:options];
        
        _pageViewController.dataSource = self;
        _pageViewController.delegate = self;
        
        PhotoContentViewController *initialViewController = [self viewControllerAtIndex:0];
        
        
        NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
        [_pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
        [self addChildViewController:_pageViewController];
        [[self view] addSubview:[_pageViewController view]];
        [_pageViewController didMoveToParentViewController:self];
        [self setPageTitle:0];
    } else {
        UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"No Photo"
                                                     message:@"No photos are available for this property"
                                                    delegate:self cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
        [av show];
    }

}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.navigationController popViewControllerAnimated:YES];

}

- (void)operation:(NSOperation*)op didFailWithError:(NSError *)error {
    [SVProgressHUD dismiss];
	//Error encountered while invoking webservice. Alert user
	UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"Sorry"
												 message:[error localizedDescription]
												delegate:self cancelButtonTitle:@"OK"
									   otherButtonTitles:nil];
	[av show];
}


-(void)setReid:(NSString *)reid {
    _reid = reid;
}



- (IBAction)pageNumber:(id)sender {
}
- (IBAction)savePhoto:(id)sender {
    if (_currentURL) {
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:_currentURL]];
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);

        id tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Info Events" action:@"Saved Photo" label:nil value:nil] build]];
    }
}



- (IBAction)doneButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
