//
//  LayerDetailCell.h
//  iMAPSmobile
//
//  Created by Justin Greco on 10/14/13.
//  Copyright (c) 2013 City of Raleigh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LayerDetailSwitch.h"
@interface LayerDetailCell : UITableViewCell
@property (weak, nonatomic) IBOutlet LayerDetailSwitch *onOff;
@property (weak, nonatomic) IBOutlet UILabel *label;

@end
