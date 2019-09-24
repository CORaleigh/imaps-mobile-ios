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

@interface PhotosViewController ()

@end

@implementation PhotosViewController
@synthesize reid = _reid, jsonOp = _jsonOp, queue = _queue, photos = _photos, pageContent = _pageContent, currentURL = _currentURL, pageViewController = _pageViewController;


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

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationController.toolbarHidden = NO;
    self.navigationController.navigationBarHidden = NO;
    self.queue = [[NSOperationQueue alloc] init];
    NSURL *url = [NSURL URLWithString:@"https://maps.raleighnc.gov/arcgis/rest/services/Property/Property/MapServer/2/query"];

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@"json" forKey:@"f"];
    [params setObject:@"*" forKey:@"outFields"];
    [params setObject:@"DATECREATED DESC" forKey:@"orderByFields"];

    [params setObject:[[@"PARCEL = '" stringByAppendingString: self.reid] stringByAppendingString:@"'"] forKey:@"where"];
    self.jsonOp = [[AGSJSONRequestOperation alloc] initWithURL:url queryParameters:params];
    self.jsonOp.target = self;
    self.jsonOp.action = @selector(operation:didSucceedWithPhotos:);
    self.jsonOp.errorAction = @selector(operation:didFailWithError:);
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD show];
    [self.queue addOperation:self.jsonOp];
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
        NSDictionary *photo = [[_photos objectAtIndex:i] objectForKey:@"attributes"];
        [urlString appendString:[photo objectForKey:@"IMAGEDIR"]];
        [urlString appendString:@"/"];
        [urlString appendString:[photo objectForKey:@"IMAGENAME"]];
    
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
    _photos = [results objectForKey:@"features"];
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

        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:NSLocalizedString(@"No Photo", nil)
                                     message:NSLocalizedString(@"No photos are available for this property", nil)
                                     preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okButton = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"OK", nil)
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       [self.navigationController popViewControllerAnimated:YES];
                                   }];
        [alert addAction:okButton];
        
        [self presentViewController:alert animated:YES completion:nil];
    }

}



- (void)operation:(NSOperation*)op didFailWithError:(NSError *)error {
    [SVProgressHUD dismiss];

    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:NSLocalizedString(@"Sorry", nil)
                                 message:[error localizedDescription]
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* okButton = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"OK", nil)
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   [self.navigationController popViewControllerAnimated:YES];
                               }];
    [alert addAction:okButton];
    
    [self presentViewController:alert animated:YES completion:nil];
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

    }
}



- (IBAction)doneButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
