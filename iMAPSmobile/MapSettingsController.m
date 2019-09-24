//
//  MapSettingsController.m
//  iMAPSmobile
//
//  Created by Justin Greco on 12/17/13.
//  Copyright (c) 2013 City of Raleigh. All rights reserved.
//

#import "MapSettingsController.h"
#import "SingletonData.h"

@interface MapSettingsController ()

@end

@implementation MapSettingsController
@synthesize segment = _segment;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.segment setSelectedSegmentIndex:([[SingletonData getSingleTapName] isEqualToString:@"identify"]) ? 0 : 1];
    

}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (@available(iOS 13, *)) {
        if(self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
            self.navigationController.navigationBar.barTintColor = [UIColor blackColor];

        } else {
            self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
        }
    }
}
-(void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    if (@available(iOS 13, *)) {
        if(self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
            self.navigationController.navigationBar.barTintColor = [UIColor blackColor];

        } else {
            self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)tapGestureChanged:(UISegmentedControl*)sender {
    [SingletonData setSingleTapName:(sender.selectedSegmentIndex == 0) ? @"identify" : @"streetview" ];
}
@end
