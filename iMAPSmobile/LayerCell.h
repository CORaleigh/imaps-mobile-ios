//
//  LayerCell.h
//  iMAPSmobile
//
//  Created by Justin Greco on 10/10/13.
//  Copyright (c) 2013 City of Raleigh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LayerSwitch.h"
#import "LayerSlider.h"

@interface LayerCell : UITableViewCell
@property (weak, nonatomic) IBOutlet LayerSwitch *onOff;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet LayerSlider *slider;

@end
