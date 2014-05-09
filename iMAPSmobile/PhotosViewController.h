//
//  PhotosViewController.h
//  iMAPSmobile
//
//  Created by Justin Greco on 10/11/13.
//  Copyright (c) 2013 City of Raleigh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>
@interface PhotosViewController : UIViewController<UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIAlertViewDelegate>
{
    UIPageViewController *pageViewController;
    NSArray *pageContent;
}

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *pageContent;

@property (strong, nonatomic) NSString *reid;
@property (strong, nonatomic) AGSJSONRequestOperation *jsonOp;
@property (strong, nonatomic) NSOperationQueue *queue;
@property (strong, nonatomic) NSArray *photos;
@property (strong, nonatomic) NSURL *currentURL;
- (IBAction)savePhoto:(id)sender;

- (IBAction)doneButtonTapped:(id)sender;
@end
